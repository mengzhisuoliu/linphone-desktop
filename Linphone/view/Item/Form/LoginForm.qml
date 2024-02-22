import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone


ColumnLayout {
	id: mainItem
	spacing: 15 * DefaultStyle.dp
	signal connectionSucceed()

	FormItemLayout {
		id: username
		label: "Username"
		mandatory: true
		enableErrorText: true
		contentItem: TextField {
			id: usernameEdit
			Layout.preferredWidth: 360 * DefaultStyle.dp
			Layout.preferredHeight: 49 * DefaultStyle.dp
			Binding on backgroundBorderColor {
				when: errorText.opacity != 0
				value: DefaultStyle.danger_500main
			}
			Binding on color {
				when: errorText.opacity != 0
				value: DefaultStyle.danger_500main
			}
		}
	}
	Item {
		Layout.preferredHeight: password.implicitHeight
		FormItemLayout {
			id: password
			label: "Password"
			mandatory: true
			enableErrorText: true
			contentItem: TextField {
				id: passwordEdit
				Layout.preferredWidth: 360 * DefaultStyle.dp
				Layout.preferredHeight: 49 * DefaultStyle.dp
				hidden: true
				Binding on backgroundBorderColor {
					when: errorText.opacity != 0
					value: DefaultStyle.danger_500main
				}
				Binding on color {
					when: errorText.opacity != 0
					value: DefaultStyle.danger_500main
				}
			}
		}

		ErrorText {
			anchors.top: password.bottom
			anchors.topMargin: 15 * DefaultStyle.dp
			id: errorText
			Connections {
				target: LoginPageCpp
				onErrorMessageChanged: {
					errorText.text = LoginPageCpp.errorMessage
				}
				onRegistrationStateChanged: {
					if (LoginPageCpp.registrationState === LinphoneEnums.RegistrationState.Ok) {
						mainItem.connectionSucceed()
					}
				}
			}
		}
	}

	RowLayout {
		id: lastFormLineLayout
		Button {
			leftPadding: 20 * DefaultStyle.dp
			rightPadding: 20 * DefaultStyle.dp
			topPadding: 11 * DefaultStyle.dp
			bottomPadding: 11 * DefaultStyle.dp
			contentItem: StackLayout {
				id: connectionButton
				currentIndex: 0
				Text {
					text: qsTr("Connexion")
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter

					font {
						pixelSize: 18 * DefaultStyle.dp
						weight: 600 * DefaultStyle.dp
					}
					color: DefaultStyle.grey_0
				}
				BusyIndicator {
					width: parent.height
					height: parent.height
					Layout.alignment: Qt.AlignCenter
					indicatorColor: DefaultStyle.grey_0
				}
				Connections {
					target: LoginPageCpp
					onRegistrationStateChanged: {
						if (LoginPageCpp.registrationState != LinphoneEnums.RegistrationState.Progress) {
							connectionButton.currentIndex = 0
						}
					}
					onErrorMessageChanged: {
						connectionButton.currentIndex = 0
					}
				}
			}
			Layout.rightMargin: 20 * DefaultStyle.dp
			onClicked: {
				username.errorMessage = ""
				password.errorMessage = ""
				errorText.text = ""

				if (usernameEdit.text.length == 0 || passwordEdit.text.length == 0) {
					if (usernameEdit.text.length == 0)
						username.errorMessage = qsTr("You must enter a username")
					if (passwordEdit.text.length == 0)
						password.errorMessage = qsTr("You must enter a password")
					return
				}
				LoginPageCpp.login(usernameEdit.text, passwordEdit.text)
				connectionButton.currentIndex = 1
			}
		}
		Button {
			background: Item {
				visible: false
			}
			contentItem: Text {
				color: DefaultStyle.main2_500main
				text: "Forgotten password?"
				font{
					underline: true
					pixelSize: 13 * DefaultStyle.dp
					weight : 600 * DefaultStyle.dp
				}
			}
			onClicked: console.debug("[LoginForm]User: forgotten password button clicked")
		}
	
	}
}
