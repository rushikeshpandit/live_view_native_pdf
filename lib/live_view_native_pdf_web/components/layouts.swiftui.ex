defmodule LiveViewNativePdfWeb.Layouts.SwiftUI do
  use LiveViewNativePdfNative, [:layout, format: :swiftui]

  embed_templates "layouts_swiftui/*"
end
