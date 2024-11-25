import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import Linphone
import UtilsCpp
import SettingsCpp

Rectangle{
	id: mainItem
	property int voicemailCount: 0
	property bool showMwi: false
	width: 42 * DefaultStyle.dp * scaleFactor
	height: 36 * DefaultStyle.dp * scaleFactor
	property real scaleFactor: 1.0
	signal clicked()
	color: 'transparent'
	Button {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		icon.source: AppIcons.voicemail
		icon.color: DefaultStyle.main2_600
		width: 33 * DefaultStyle.dp * scaleFactor
		height: width
		icon.width: width
		icon.height: width
		padding: 0
		background: Item {
			anchors.fill: parent
		}
		onClicked: {
			mainItem.clicked()
		}
	}
	Text {
		anchors.top: parent.top
		anchors.right: parent.right
		width: 14 * DefaultStyle.dp * scaleFactor
		height: width
		horizontalAlignment: Text.AlignHCenter
		font.weight: 700 * DefaultStyle.dp
		font.pixelSize: 13 * DefaultStyle.dp * scaleFactor
		color: DefaultStyle.danger_500main
		text: voicemailCount >= 100 ? '99+' : voicemailCount
		visible: showMwi && voicemailCount > 0
		maximumLineCount: 1
	}

	Rectangle {
		anchors.top: parent.top
		anchors.right: parent.right
		color: DefaultStyle.danger_500main
		visible: showMwi && voicemailCount == 0
		width: 14 * DefaultStyle.dp * scaleFactor
		height: width
		radius: width / 2
		EffectImage {
			anchors.fill: parent
			anchors.margins: 1.5 * DefaultStyle.dp * scaleFactor
			imageSource: AppIcons.bellMwi
			colorizationColor: DefaultStyle.grey_0
		}
	}

}
