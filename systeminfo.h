#ifndef SYSTEMINFO_H
#define SYSTEMINFO_H

#include <QObject>
#include <QTimer>
#include <QFile>
#include <QTextStream>
#include <QStringList>
#include <QVariantList>

class SystemInfo : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double cpuLoad READ cpuLoad NOTIFY dataChanged)
    Q_PROPERTY(QString memUsage READ memUsage NOTIFY dataChanged)
    Q_PROPERTY(double memPercent READ memPercent NOTIFY dataChanged)
    Q_PROPERTY(QString diskIO READ diskIO NOTIFY dataChanged)
    Q_PROPERTY(int processCount READ processCount NOTIFY dataChanged)
    Q_PROPERTY(QString netIO READ netIO NOTIFY dataChanged)
    Q_PROPERTY(QString cpuTemp READ cpuTemp NOTIFY dataChanged)
    Q_PROPERTY(QVariantList cpuHistory READ cpuHistory NOTIFY dataChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    double      cpuLoad()      const { return m_cpuLoad; }
    QString     memUsage()     const { return m_memUsage; }
    double      memPercent()   const { return m_memPercent; }
    QString     diskIO()       const { return m_diskIO; }
    int         processCount() const { return m_processCount; }
    QString     netIO()        const { return m_netIO; }
    QString     cpuTemp()      const { return m_cpuTemp; }
    QVariantList cpuHistory()  const { return m_cpuHistory; }

signals:
    void dataChanged();

public slots:
    void updateStats();

private:
    double       m_cpuLoad     = 0.0;
    QString      m_memUsage    = "0 / 0 MB";
    double       m_memPercent  = 0.0;
    QString      m_diskIO      = "R: 0 KB/s  W: 0 KB/s";
    int          m_processCount = 0;
    QString      m_netIO       = "↑ 0 KB/s  ↓ 0 KB/s";
    QString      m_cpuTemp     = "N/A";
    QVariantList m_cpuHistory;          // 最近 60 个采样点 (0.0 ~ 1.0)

    // 差值暂存
    long long lastTotal = 0, lastActive = 0;
    long long lastDiskRead = 0, lastDiskWrite = 0;
    long long lastNetTx = 0,   lastNetRx = 0;

    // 辅助
    QString formatBytes(double kb) const;
};

#endif // SYSTEMINFO_H
