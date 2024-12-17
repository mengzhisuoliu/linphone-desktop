import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import Linphone
import SettingsCpp 1.0
import UtilsCpp

AbstractSettingsLayout {
	id: mainItem
	width: parent?.width
	contentModel: [
		{
			title: qsTr("Paramètres"),
			subTitle: "",
			contentComponent: generalParametersComponent
		},
		{
			title: qsTr("Paramètres de compte"),
			subTitle: "",
			contentComponent: advancedParametersComponent
		}
	]

	property alias account: mainItem.model

	onSave: {
		account.core.save()
	}
	onUndo: account.core.undo()
	Connections {
		target: account.core
		function onIsSavedChanged() {
			if (account.core.isSaved) UtilsCpp.showInformationPopup(qsTr("Succès"), qsTr("Les changements ont été sauvegardés"), true, mainWindow)
		}
	}
	
	// General parameters
	/////////////////////

	Component {
		id: generalParametersComponent
		ColumnLayout {
			id: column
			Layout.fillWidth: true
			spacing: 20 * DefaultStyle.dp
			DecoratedTextField {
				propertyName: "mwiServerAddress"
				propertyOwner: account.core
				title: qsTr("URI du serveur de messagerie vocale")
				Layout.fillWidth: true
				isValid: function(text) { return text.length == 0 || !text.endsWith(".") } // work around sdk crash when adress ends with .
				toValidate: true
			}
			DecoratedTextField {
				propertyName: "voicemailAddress"
				propertyOwner: account.core
				title: qsTr("URI de messagerie vocale")
				Layout.fillWidth: true
			}
		}
	}

	// Advanced parameters
	/////////////////////

	Component {
		id: advancedParametersComponent
		ColumnLayout {
			Layout.fillWidth: true
			spacing: 20 * DefaultStyle.dp
			Text {
				text: qsTr("Transport")
				color: DefaultStyle.main2_600
				font: Typography.p2l
			}
			ComboSetting {
				Layout.fillWidth: true
				Layout.topMargin: -15 * DefaultStyle.dp
				entries: account.core.transports
				propertyName: "transport"
				propertyOwner: account.core
			}
			DecoratedTextField {
				Layout.fillWidth: true
				title: qsTr("URL du serveur mandataire")
				propertyName: "serverAddress"
				propertyOwner: account.core
			}
			SwitchSetting {
				titleText: qsTr("Serveur mandataire sortant")
				propertyName: "outboundProxyEnabled"
				propertyOwner: account.core
			}
			DecoratedTextField {
				Layout.fillWidth: true
				propertyName: "stunServer"
				propertyOwner: account.core
				title: qsTr("Adresse du serveur STUN")
			}
			SwitchSetting {
				titleText: qsTr("Activer ICE")
				propertyName: "iceEnabled"
				propertyOwner: account.core
			}
			SwitchSetting {
				titleText: qsTr("AVPF")
				propertyName: "avpfEnabled"
				propertyOwner: account.core
			}
			SwitchSetting {
				titleText: qsTr("Mode bundle")
				propertyName: "bundleModeEnabled"
				propertyOwner: account.core
			}
			DecoratedTextField {
				Layout.fillWidth: true
				propertyName: "expire"
				propertyOwner: account.core
				title: qsTr("Expiration (en seconde)")
				canBeEmpty: false
				isValid: function(text) { return !isNaN(Number(text)) }
				toValidate: true
			}
			DecoratedTextField {
				Layout.fillWidth: true
				title: qsTr("URI de l’usine à conversations")
				propertyName: "conferenceFactoryAddress"
				propertyOwner: account.core
			}
			DecoratedTextField {
				Layout.fillWidth: true
				title: qsTr("URI de l’usine à réunions")
				propertyName: "audioVideoConferenceFactoryAddress"
				propertyOwner: account.core
				visible: !SettingsCpp.disableMeetingsFeature
			}
			DecoratedTextField {
				Layout.fillWidth: true
				title: qsTr("URL du serveur d’échange de clés de chiffrement")
				propertyName: "limeServerUrl"
				propertyOwner: account.core
			}
		}
	}
}
