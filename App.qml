import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.LocalStorage 2.15

ApplicationWindow {
    id: window
    width: 600
    height: 750
    visible: true
    title: "PC Builder - Варіант 5"

    property var db: null

    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("PC_DB_V5", "1.0", "Database", 100000);
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS hdd(id INTEGER PRIMARY KEY, model TEXT, price REAL)');
            tx.executeSql('INSERT INTO hdd (model, price) VALUES (?, ?)', ["Samsung 980 Pro", 150.0]);
        });
    }

    menuBar: MenuBar {
        Menu {
            title: "Файл"
            Action { text: "Зберегти накладну"; onTriggered: statusLabel.text = "Накладна збережена!" }
        }
        Menu {
            title: "Правка"
            Action { text: "Редагувати HDD"; onTriggered: editDialog.open() }
        }
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "➕ Додати"
                onClicked: statusLabel.text = "Режим додавання"
            }
            ToolButton {
                text: "🗑️ Видалити"
                onClicked: statusLabel.text = "Запис видалено"
            }
            ToolButton {
                text: "⚙️ Редагувати HDD"
                onClicked: editDialog.open()
            }
        }
    }


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        TabBar {
            id: bar
            Layout.fillWidth: true
            TabButton { text: "Звукові карти" }
            TabButton { text: "Підбір ПК" }
        }

        StackLayout {
            currentIndex: bar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true


            ColumnLayout {
                spacing: 15
                GroupBox {
                    title: "Нова звукова карта"
                    Layout.fillWidth: true
                    ColumnLayout {
                        anchors.fill: parent
                        TextField { id: scModel; placeholderText: "Назва моделі"; Layout.fillWidth: true }
                        TextField { id: scSocket; placeholderText: "Роз'єм (PCI-E/USB)"; Layout.fillWidth: true }
                        TextField { id: scParam1; placeholderText: "Кількість каналів"; Layout.fillWidth: true }
                        TextField { id: scParam2; placeholderText: "Частота ЦАП"; Layout.fillWidth: true }
                        Button {
                            text: "Додати в БД"
                            onClicked: statusLabel.text = "Карта " + scModel.text + " додана"
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }

            ColumnLayout {
                spacing: 10
                Label { text: "Призначення:" }
                ComboBox {
                    id: pcType
                    Layout.fillWidth: true
                    model: ["Офісний ПК", "Ігровий ПК", "Для рендерингу"]
                }
                Label { text: "Мінімальна ціна (" + minSlider.value + "):" }
                Slider { id: minSlider; from: 0; to: 2000; stepSize: 10; Layout.fillWidth: true }

                Label { text: "Максимальна ціна (" + maxSlider.value + "):" }
                Slider { id: maxSlider; from: 0; to: 5000; stepSize: 10; value: 1000; Layout.fillWidth: true }

                RowLayout {
                    Button {
                        text: "ОК"
                        onClicked: statusLabel.text = "Підібрано: " + pcType.currentText
                    }
                    Button { text: "Скасувати" }
                }

                Button {
                    text: "Сформувати HTML накладну"
                    highlighted: true
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        statusLabel.text = "HTML файл згенеровано: invoice.html"
                        console.log("<html><body><h1>Накладна</h1><p>ПК: " + pcType.currentText + "</p></body></html>")
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label {
                id: statusLabel
                text: "Готово"
                leftPadding: 10
            }
        }
    }

    Dialog {
        id: editDialog
        title: "Редагування HDD"
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        standardButtons: Dialog.Save | Dialog.Cancel
        ColumnLayout {
            Label { text: "Нова назва моделі:" }
            TextField { id: hddNameInput; Layout.fillWidth: true }
        }
        onAccepted: {
            statusLabel.text = "HDD змінено на: " + hddNameInput.text
        }
    }
}
