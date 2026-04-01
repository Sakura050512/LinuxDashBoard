#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include "systeminfo.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    SystemInfo sysInfo;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("sysData", &sysInfo);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (!engine.rootObjects().isEmpty()) {
        QQuickWindow *window = qobject_cast<QQuickWindow*>(engine.rootObjects().at(0));
        if (window) {
            window->setFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint | Qt::Tool);
            window->setColor(QColor(Qt::transparent));
        }
    }

    return app.exec();
}
