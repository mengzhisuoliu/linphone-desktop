import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp

AbstractSettingsMenu {
	layoutsPath: "qrc:/qt/qml/Linphone/view/Page/Layout/Settings"
	titleText: qsTr("Mon compte")
	property AccountGui account
	signal accountRemoved()
	families: [
		{title: qsTr("Général"), layout: "AccountSettingsGeneralLayout", model: account},
		{title: qsTr("Paramètres de compte"), layout: "AccountSettingsParametersLayout", model: account}
	]
	Connections {
		target: account.core
		onRemoved: accountRemoved()
	}
}
