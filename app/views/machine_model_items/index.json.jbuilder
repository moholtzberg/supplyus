json.array!(@machine_model_items) do |machine_model_item|
  json.extract! machine_model_item, :id
  json.url machine_model_item_url(machine_model_item, format: :json)
end
