#ifndef WIDGETMANAGER_H
#define WIDGETMANAGER_H

#include <QObject>
#include <QQuickView>
#include <QList>

class WidgetManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal globalOpacity READ globalOpacity WRITE setGlobalOpacity NOTIFY globalOpacityChanged)

public:
    explicit WidgetManager(QObject *parent = nullptr);

    // 给 QML 调用的接口：控制子窗口开关
    Q_INVOKABLE void toggleWidget(const QString &name);

    // 统一设置透明度
    void setGlobalOpacity(qreal opacity);
    qreal globalOpacity() const { return m_globalOpacity; }

signals:
    void globalOpacityChanged();

private:
    QMap<QString, QQuickView*> m_widgets;
    qreal m_globalOpacity = 0.9;

    void createWidget(const QString &name, const QString &source);
};

#endif
