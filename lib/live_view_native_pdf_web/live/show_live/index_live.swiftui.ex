defmodule LiveViewNativePdfWeb.ShowLive.IndexLive.SwiftUI do
  use LiveViewNativePdfNative, [:render_component, format: :swiftui]

  def render(assigns) do
    ~LVN"""
    <HStack id="splash-ios" style={"foregroundStyle(.red)"}>
      <.button style="frame(maxWidth: .infinity) " phx-click="previous_page"><.icon name="backward.fill" /></.button>
      <.button style="frame(maxWidth: .infinity)" phx-click="next_page"><.icon name="forward.fill" /></.button>
    </HStack>
    """
  end
end
