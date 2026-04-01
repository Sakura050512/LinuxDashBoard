#include "systeminfo.h"
#include <QDir>

SystemInfo::SystemInfo(QObject *parent) : QObject(parent)
{
    for (int i = 0; i < 60; ++i)
        m_cpuHistory.append(0.0);

    QTimer *timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &SystemInfo::updateStats);
    timer->start(1000);
    updateStats();
}

QString SystemInfo::formatBytes(double kb) const
{
    if (kb >= 1024.0 * 1024.0)
        return QString("%1 GB/s").arg(kb / 1024.0 / 1024.0, 0, 'f', 2);
    if (kb >= 1024.0)
        return QString("%1 MB/s").arg(kb / 1024.0, 0, 'f', 1);
    return QString("%1 KB/s").arg(kb, 0, 'f', 1);
}

void SystemInfo::updateStats()
{
    // ── 1. 内存 ───────────────────────────────────────────────────
    QFile memFile("/proc/meminfo");
    if (memFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        long long total = 0, avail = 0;
        char buf[256];
        while (memFile.readLine(buf, sizeof(buf)) > 0) {
            QString line = QString::fromLocal8Bit(buf).trimmed();
            if (line.startsWith("MemTotal:")) {
                total = line.mid(9).trimmed()
                            .split(" ", QString::SkipEmptyParts)
                            .first().toLongLong();
            } else if (line.startsWith("MemAvailable:")) {
                avail = line.mid(13).trimmed()
                            .split(" ", QString::SkipEmptyParts)
                            .first().toLongLong();
            }
            if (total > 0 && avail > 0) break;
        }
        memFile.close();
        if (total > 0) {
            long long used = total - avail;
            m_memUsage   = QString("%1 / %2 MB").arg(used / 1024).arg(total / 1024);
            m_memPercent = (double)used / total;
        }
    }

    // ── 2. CPU ────────────────────────────────────────────────────
    QFile cpuFile("/proc/stat");
    if (cpuFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString line = cpuFile.readLine();
        cpuFile.close();
        QStringList p = line.trimmed().split(" ", QString::SkipEmptyParts);
        if (p.size() >= 5) {
            long long user   = p[1].toLongLong();
            long long nice   = p[2].toLongLong();
            long long sys    = p[3].toLongLong();
            long long idle   = p[4].toLongLong();
            long long iowait = (p.size() > 5) ? p[5].toLongLong() : 0;
            long long total  = user + nice + sys + idle + iowait;
            long long active = total - idle - iowait;
            if (lastTotal > 0) {
                long long dt = total  - lastTotal;
                long long da = active - lastActive;
                m_cpuLoad = (dt > 0) ? qBound(0.0, (double)da / dt, 1.0) : 0.0;
            }
            lastTotal  = total;
            lastActive = active;
        }
    }
    m_cpuHistory.removeFirst();
    m_cpuHistory.append(m_cpuLoad);

    // ── 3. 磁盘 I/O ───────────────────────────────────────────────
    QFile diskFile("/proc/diskstats");
    if (diskFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        long long curRead = 0, curWrite = 0;
        char buf[512];
        while (diskFile.readLine(buf, sizeof(buf)) > 0) {
            QString line = QString::fromLocal8Bit(buf).trimmed();
            QStringList parts = line.split(" ", QString::SkipEmptyParts);
            if (parts.size() < 14) continue;
            QString dev = parts[2];
            bool isSd   = dev.startsWith("sd")   && dev.length() == 3;
            bool isNvme = dev.startsWith("nvme")  && !dev.contains("p");
            bool isVd   = dev.startsWith("vd")    && dev.length() == 3;
            if (isSd || isNvme || isVd) {
                curRead  += parts[5].toLongLong();
                curWrite += parts[9].toLongLong();
            }
        }
        diskFile.close();
        if (lastDiskRead > 0) {
            double rKB = (curRead  - lastDiskRead)  * 512.0 / 1024.0;
            double wKB = (curWrite - lastDiskWrite) * 512.0 / 1024.0;
            m_diskIO = QString("R: %1   W: %2")
                       .arg(formatBytes(rKB)).arg(formatBytes(wKB));
        }
        lastDiskRead  = curRead;
        lastDiskWrite = curWrite;
    }

    // ── 4. 进程数 ─────────────────────────────────────────────────
    QFile procFile("/proc/loadavg");
    if (procFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString content = procFile.readAll().trimmed();
        procFile.close();
        QStringList parts = content.split(" ", QString::SkipEmptyParts);
        if (parts.size() >= 4)
            m_processCount = parts[3].split("/").last().toInt();
    }

    // ── 5. 网络流量 ───────────────────────────────────────────────
    QFile netFile("/proc/net/dev");
    if (netFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&netFile);
        in.readLine(); in.readLine();
        long long curRx = 0, curTx = 0;
        while (!in.atEnd()) {
            QString line = in.readLine().trimmed();
            line.replace(":", " ");
            QStringList p = line.split(" ", QString::SkipEmptyParts);
            if (p.size() < 10) continue;
            if (p[0] == "lo") continue;
            curRx += p[1].toLongLong();
            curTx += p[9].toLongLong();
        }
        netFile.close();
        if (lastNetRx > 0) {
            double rxKB = (curRx - lastNetRx) / 1024.0;
            double txKB = (curTx - lastNetTx) / 1024.0;
            m_netIO = QString("↑ %1   ↓ %2")
                      .arg(formatBytes(txKB)).arg(formatBytes(rxKB));
        }
        lastNetRx = curRx;
        lastNetTx = curTx;
    }

    // ── 6. CPU 温度 ───────────────────────────────────────────────
    m_cpuTemp = "N/A";
    QDir hwmon("/sys/class/hwmon");
    if (hwmon.exists()) {
        for (const QString &entry : hwmon.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
            QFile nameFile(hwmon.filePath(entry + "/name"));
            if (nameFile.open(QIODevice::ReadOnly)) {
                QString name = nameFile.readAll().trimmed();
                nameFile.close();
                if (name == "coretemp" || name == "k10temp" || name == "zenpower") {
                    QFile tempFile(hwmon.filePath(entry + "/temp1_input"));
                    if (tempFile.open(QIODevice::ReadOnly)) {
                        int milli = tempFile.readAll().trimmed().toInt();
                        tempFile.close();
                        m_cpuTemp = QString("%1 °C").arg(milli / 1000);
                        break;
                    }
                }
            }
        }
    }
    if (m_cpuTemp == "N/A") {
        QFile tz("/sys/class/thermal/thermal_zone0/temp");
        if (tz.open(QIODevice::ReadOnly)) {
            int milli = tz.readAll().trimmed().toInt();
            tz.close();
            if (milli > 0)
                m_cpuTemp = QString("%1 °C").arg(milli / 1000);
        }
    }

    emit dataChanged();
}
