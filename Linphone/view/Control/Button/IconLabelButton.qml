import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Linphone

Button {
	id: mainItem
	icon.width: 24 * DefaultStyle.dp
	icon.height: 24 * DefaultStyle.dp
	textSize: 14 * DefaultStyle.dp
	textWeight: 400 * DefaultStyle.dp
	radius: 5 * DefaultStyle.dp
	shadowEnabled: mainItem.activeFocus || hovered
	style: ButtonStyle.hoveredBackground
	
	contentItem: RowLayout {
		EffectImage {
			imageSource: mainItem.icon.source
			imageWidth: mainItem.icon.width
			imageHeight: mainItem.icon.height
			colorizationColor: mainItem.pressed 
				? mainItem.pressedImageColor 
				: mainItem.hovered
					? mainItem.hoveredImageColor
					: mainItem.contentImageColor
			Layout.preferredWidth: mainItem.icon.width
			Layout.preferredHeight: mainItem.icon.height
		}
		Text{
			horizontalAlignment: mainItem.textHAlignment
			verticalAlignment: Text.AlignLeft
			Layout.preferredWidth: textMetrics.advanceWidth
			wrapMode: Text.WrapAnywhere
			text: mainItem.text
			maximumLineCount: 1
			color: pressed
				? mainItem.pressedTextColor
				: mainItem.hovered
					? mainItem.hoveredTextColor
					: mainItem.textColor
			font {
				pixelSize: mainItem.textSize
				weight: mainItem.textWeight
				family: DefaultStyle.defaultFont
				capitalization: mainItem.capitalization
				underline: mainItem.underline
				bold: mainItem.style === ButtonStyle.noBackground && (mainItem.hovered || mainItem.pressed)
			}
			TextMetrics {
				id: textMetrics
				text: mainItem.text
				font.bold: true
			}
		}
		Item{Layout.fillWidth: true}
	}
}
