class AddSvgToRadicals < ActiveRecord::Migration[5.2]
  def change
    add_column :wk_radicals, :svg, :string
  end
end
