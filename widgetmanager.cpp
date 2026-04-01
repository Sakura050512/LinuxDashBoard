#include "widgetmanager.h"
#include <QColor>

WidgetManager::WidgetManager(QObject *parent) : QObject(parent) {
    // 初始化子部件，但不立即显示
    createWidget("clock", "qrc:/ClockWidget.qml");
    createWidget("monitor", "qrc:/MonitorWidget.qml");
    createWidget("notes", "qrc:/NotesWidget.qml");
}

void WidgetManager::createWidget(const QString &name, const QString &source) {
    QQuickView* view = new QQuickView();

    // 设置基本特征 (核心要求)
    view->setFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint | Qt::Tool);
    view->setColor(QColor(Qt::transparent));
    view->setSource(QUrl(source));

    m_widgets.insert(name, view);
}

void WidgetManager::toggleWidget(const QString &name) {
    if (m_widgets.contains(name)) {
        QQuickView* v = m_widgets[name];
        v->isVisible() ? v->hide() : v->show();
    }
}

void WidgetManager::setGlobalOpacity(qreal opacity) {
    m_globalOpacity = opacity;
    for(auto v : m_widgets) v->setOpacity(opacity);
    emit globalOpacityChanged();
}
