/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DevicePage {
	id: root

	title: 	{
		if (device.customName) {
			return device.customName
		} else if (device.deviceInstance >= 0 && device.productName) {
			return `${device.productName} (${device.deviceInstance})`
		} else {
			return ""
		}
	}

	settingsHeader: SettingsColumn {
		width: parent?.width ?? 0
		bottomPadding: spacing

		ListText {
			//% "Module state"
			text: qsTrId("settings_module_state")
			dataItem.uid: root.serviceUid + "/State"
			secondaryText: VenusOS.switch_deviceStateToText(dataItem.value)
		}

		ListQuantity {
			//% "Module Voltage"
			text: qsTrId("settings_module_voltage")
			dataItem.uid: root.serviceUid + "/ModuleVoltage"
			preferredVisible: dataItem.valid
			unit: VenusOS.Units_Volt_DC
			precision: 1
		}

		ListNavigation {
			//% "Channel configuration"
			text: qsTrId("settings_switch_channel_configuration")
			preferredVisible: channelModel.rowCount > 0
			onClicked: Global.pageManager.pushPage(channelConfigPageComponent, { title: text })

			VeQItemTableModel {
				id: channelModel
				uids: [ root.serviceUid + "/Channel" ]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}

			Component {
				id: channelConfigPageComponent

				Page {
					GradientListView {
						model: channelModel
						delegate: ListRadioButtonGroup {
							required property int index
							required property string uid

							//: The direction of the channel (unknown/output/input). %1 = channel number
							//% "Channel %1"
							text: qsTrId("settings_switch_channel_direction").arg(index + 1)
							dataItem.uid: uid + "/Direction"
							writeAccessLevel: VenusOS.User_AccessType_User
							optionModel: [
								{ display: CommonWords.unknown_status, value: -1 },
								//: Configure channel to use "output" direction
								//% "Output"
								{ display: qsTrId("settings_switch_channel_output"), value: 0 },
								//: Configure channel to use "input" direction
								//% "Input"
								{ display: qsTrId("settings_switch_channel_input"), value: 1 },
							]
						}
					}
				}
			}
		}
	}
}
