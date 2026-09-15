import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "custom.rounded-corner-blur"

  property bool popupOpen: false

  function close() {
    popupOpen = false
    cursorActive = false
    focusSection = "presets"
    selectedIndex = 0
  }

  implicitWidth: button.implicitWidth
  implicitHeight: barSize

  readonly property color foreground: root.bar ? root.bar.foreground : Color.foreground
  readonly property color accent: Color.accent
  readonly property string fontFamily: root.bar ? root.bar.fontFamily : Style.font.family

  property int rounding: 0
  property real activeOpacity: 1.0
  property real inactiveOpacity: 1.0
  property bool blurEnabled: false
  property int blurSize: 8
  property int blurPasses: 1

  readonly property var presets: [
    { name: "Default", rounding: 0,    active: 1.0, inactive: 1.0, blur: false, size: 8,  passes: 1 },
    { name: "Rounded", rounding: 14,   active: 1.0, inactive: 1.0, blur: false, size: 8,  passes: 1 },
    { name: "Glass",   rounding: 14,   active: 0.88, inactive: 0.80, blur: true, size: 8,  passes: 2 },
    { name: "Frosted", rounding: 10,   active: 0.90, inactive: 0.85, blur: true, size: 12, passes: 3 },
    { name: "Minimal", rounding: 6,    active: 0.92, inactive: 0.85, blur: true, size: 6,  passes: 2 }
  ]

  function applyPreset(index) {
    var p = presets[index]
    if (!p) return
    rounding = p.rounding
    activeOpacity = p.active
    inactiveOpacity = p.inactive
    blurEnabled = p.blur
    blurSize = p.size
    blurPasses = p.passes
    apply()
  }

  function resetToDefaults() {
    resetProcess.running = true
  }

  readonly property var sections: root.blurEnabled
    ? ["rounding", "active", "inactive", "blur", "size", "passes", "presets", "reset"]
    : ["rounding", "active", "inactive", "blur", "presets", "reset"]

  property string focusSection: "presets"
  property int selectedIndex: 0
  property bool cursorActive: false

  function sectionHasSlider(section) {
    return section === "rounding" || section === "active" || section === "inactive"
      || section === "size" || section === "passes"
  }

  function moveCursor(delta) {
    if (!sections || sections.length === 0) return
    var sIdx = sections.indexOf(focusSection)
    if (sIdx < 0) { focusSection = sections[0]; selectedIndex = sectionHasSlider(focusSection) ? -1 : 0; return }
    var max = focusSection === "presets" ? presets.length - 1 : 0
    if (delta > 0) {
      if (focusSection === "presets" && selectedIndex < max) { selectedIndex = selectedIndex + 1; return }
      if (sIdx < sections.length - 1) {
        focusSection = sections[sIdx + 1]
        selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
      }
    } else {
      if (focusSection === "presets" && selectedIndex > 0) { selectedIndex = selectedIndex - 1; return }
      if (sIdx > 0) {
        focusSection = sections[sIdx - 1]
        selectedIndex = sectionHasSlider(focusSection) ? -1 : 0
      }
    }
  }

  function adjust(delta) {
    if (focusSection === "rounding") {
      rounding = clampInt(rounding + delta, 0, 30)
    } else if (focusSection === "active") {
      activeOpacity = clamp01(activeOpacity + delta * 0.05)
    } else if (focusSection === "inactive") {
      inactiveOpacity = clamp01(inactiveOpacity + delta * 0.05)
    } else if (focusSection === "blur") {
      blurEnabled = !blurEnabled
    } else if (focusSection === "size") {
      blurSize = clampInt(blurSize + delta * (blurSize >= 16 ? 2 : 1), 0, 32)
    } else if (focusSection === "passes") {
      blurPasses = clampInt(blurPasses + delta, 1, 6)
    } else if (focusSection === "presets") {
      selectedIndex = Math.max(0, Math.min(presets.length - 1, selectedIndex + delta))
      return
    }
    apply()
  }

  function clampInt(v, lo, hi) { return Math.max(lo, Math.min(hi, Math.round(v))) }
  function clamp01(v) { return Math.max(0, Math.min(1, v)) }

  function activate() {
    if (focusSection === "blur") {
      blurEnabled = !blurEnabled
      apply()
    } else if (focusSection === "presets") {
      applyPreset(selectedIndex)
    } else if (focusSection === "reset") {
      resetToDefaults()
    }
  }

  Process {
    id: loadProcess
    running: false
    command: ["bash", "-c",
      "hyprctl getoption decoration:rounding -j ; "
      + "hyprctl getoption decoration:active_opacity -j ; "
      + "hyprctl getoption decoration:inactive_opacity -j ; "
      + "hyprctl getoption decoration:blur:enabled -j ; "
      + "hyprctl getoption decoration:blur:size -j ; "
      + "hyprctl getoption decoration:blur:passes -j"]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseLoaded(text)
    }
  }

  function parseLoaded(output) {
    var lines = String(output || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (line.indexOf("{") !== 0) continue
      var parsed = null
      try { parsed = JSON.parse(line) } catch (e) { continue }
      if (!parsed || !parsed.option) continue
      switch (parsed.option) {
      case "decoration:rounding": root.rounding = parsed.int; break
      case "decoration:active_opacity": root.activeOpacity = parsed.float; break
      case "decoration:inactive_opacity": root.inactiveOpacity = parsed.float; break
      case "decoration:blur:enabled": root.blurEnabled = parsed.bool === true; break
      case "decoration:blur:size": root.blurSize = parsed.int; break
      case "decoration:blur:passes": root.blurPasses = parsed.int; break
      }
    }
  }

  function loadValues() {
    if (!loadProcess.running) loadProcess.running = true
  }

  function stateFileScript(body) {
    return "mkdir -p \"$HOME/.local/state/omarchy\" ; "
      + "cat > \"$HOME/.local/state/omarchy/appearance.lua\" <<'LUAEOF'\n"
      + body + "LUAEOF\n"
      + "hyprctl reload >/dev/null 2>&1"
  }

  Process {
    id: applyProcess
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.afterApply(text)
    }
  }

  function apply() {
    var body = "return {\n"
      + "  rounding = " + Math.round(root.rounding) + ",\n"
      + "  active_opacity = " + root.activeOpacity.toFixed(2) + ",\n"
      + "  inactive_opacity = " + root.inactiveOpacity.toFixed(2) + ",\n"
      + "  blur = { enabled = " + (root.blurEnabled ? "true" : "false")
      + ", size = " + Math.round(root.blurSize)
      + ", passes = " + Math.round(root.blurPasses) + " },\n"
      + "}\n"
    applyProcess.command = ["bash", "-c", stateFileScript(body)]
    applyProcess.running = true
  }

  Process {
    id: resetProcess
    running: false
    command: ["bash", "-c",
      "rm -f \"$HOME/.local/state/omarchy/appearance.lua\" ; "
      + "hyprctl reload >/dev/null 2>&1"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.afterApply(text)
    }
  }

  function afterApply(output) {
    Qt.callLater(loadValues)
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf0db"
    tooltipText: "Window appearance"
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.popupOpen = !root.popupOpen
    }
  }

  KeyboardPanel {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.popupOpen
    focusTarget: keyCatcher
    contentWidth: popup.fittedContentWidth(Style.space(420))
    contentHeight: popup.fittedContentHeight(controlsColumn.implicitHeight + Style.space(28))

    onVisibleChanged: {
      if (visible) {
        loadValues()
        cursorActive = true
        focusSection = "presets"
        selectedIndex = 0
      }
    }

    Item {
      anchors.fill: parent

      PanelKeyCatcher {
        id: keyCatcher
        anchors.fill: parent
        onMoveRequested: function(dx, dy) {
          if (dy !== 0) root.moveCursor(dy)
          else if (dx !== 0) root.adjust(dx)
        }
        onActivateRequested: root.activate()
        onCloseRequested: root.close()
        onTabRequested: function(direction) { root.moveCursor(direction) }
      }

      Column {
        id: controlsColumn
        anchors.fill: parent
        anchors.leftMargin: Style.spacing.panelGap
        anchors.rightMargin: Style.spacing.panelGap
        anchors.topMargin: Style.space(12)
        anchors.bottomMargin: Style.space(12)
        spacing: Style.spacing.md

        SliderRow {
          label: "Rounded corners"
          valueText: root.rounding === 0 ? "0" : root.rounding + ""
          sliderValue: root.rounding
          sliderMin: 0
          sliderMax: 30
          sliderStep: 1
          sliderInteger: true
          hasCursor: root.cursorActive && root.focusSection === "rounding"
          onValueChanged: { root.rounding = __value; root.apply() }
        }

        SliderRow {
          label: "Active opacity"
          valueText: Math.round(root.activeOpacity * 100) + "%"
          sliderValue: root.activeOpacity
          sliderMin: 0.5
          sliderMax: 1.0
          sliderStep: 0.01
          hasCursor: root.cursorActive && root.focusSection === "active"
          onValueChanged: { root.activeOpacity = __value; root.apply() }
        }

        SliderRow {
          label: "Inactive opacity"
          valueText: Math.round(root.inactiveOpacity * 100) + "%"
          sliderValue: root.inactiveOpacity
          sliderMin: 0.5
          sliderMax: 1.0
          sliderStep: 0.01
          hasCursor: root.cursorActive && root.focusSection === "inactive"
          onValueChanged: { root.inactiveOpacity = __value; root.apply() }
        }

        Row {
          width: parent.width
          spacing: Style.spacing.md

          Text {
            width: Style.space(110)
            anchors.verticalCenter: parent.verticalCenter
            text: "Blur"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
          }

          ToggleSwitch {
            checked: root.blurEnabled
            interactive: true
            foreground: root.foreground
            accent: root.accent
            hasCursor: root.cursorActive && root.focusSection === "blur"
            onToggled: {
              root.blurEnabled = !root.blurEnabled
              root.apply()
            }
          }
        }

        Column {
          visible: root.blurEnabled
          width: parent.width
          spacing: Style.spacing.md

          SliderRow {
            label: "Blur size"
            valueText: root.blurSize === 0 ? "0" : root.blurSize + ""
            sliderValue: root.blurSize
            sliderMin: 0
            sliderMax: 32
            sliderStep: 1
            sliderInteger: true
            hasCursor: root.cursorActive && root.focusSection === "size"
            onValueChanged: { root.blurSize = __value; root.apply() }
          }

          SliderRow {
            label: "Blur passes"
            valueText: root.blurPasses + ""
            sliderValue: root.blurPasses
            sliderMin: 1
            sliderMax: 6
            sliderStep: 1
            sliderInteger: true
            hasCursor: root.cursorActive && root.focusSection === "passes"
            onValueChanged: { root.blurPasses = __value; root.apply() }
          }
        }

        Text {
          width: parent.width
          text: "PRESETS"
          color: Qt.darker(root.foreground, 1.5)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 1
          font.bold: true
          topPadding: Style.spacing.sm
        }

        Row {
          width: parent.width
          spacing: Style.spacing.sm

          Repeater {
            model: root.presets

            Button {
              required property var modelData
              required property int index
              text: modelData.name
              hasCursor: root.cursorActive && root.focusSection === "presets"
                && root.selectedIndex === index
              onClicked: root.applyPreset(index)
            }
          }
        }

        Button {
          width: parent.width
          text: "Reset to default"
          hasCursor: root.cursorActive && root.focusSection === "reset"
          onClicked: root.resetToDefaults()
        }
      }
    }
  }

  component SliderRow: Item {
    id: row
    property string label: ""
    property string valueText: ""
    property real sliderValue: 0
    property real sliderMin: 0
    property real sliderMax: 1
    property real sliderStep: 0.05
    property bool sliderInteger: false
    property bool hasCursor: false

    signal valueChanged(real __value)

    implicitWidth: parent ? parent.width : Style.space(360)
    implicitHeight: Math.max(Style.space(28), slider.implicitHeight)

    Text {
      id: labelText
      width: Style.space(110)
      anchors.verticalCenter: parent.verticalCenter
      text: row.label
      color: row.hasCursor ? Style.hoverStateColor(root.foreground, root.accent) : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }

    PanelSlider {
      id: slider
      anchors.left: labelText.right
      anchors.right: valueText.left
      anchors.leftMargin: Style.spacing.md
      anchors.rightMargin: Style.spacing.md
      anchors.verticalCenter: parent.verticalCenter
      bar: root.bar
      value: row.sliderValue
      minimum: row.sliderMin
      maximum: row.sliderMax
      step: row.sliderStep
      integer: row.sliderInteger
      onReleased: function(v) { row.valueChanged(v) }
    }

    Text {
      id: valueText
      width: Style.space(48)
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      horizontalAlignment: Text.AlignRight
      text: row.valueText
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }
  }
}
