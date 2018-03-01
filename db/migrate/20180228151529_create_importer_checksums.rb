class CreateImporterChecksums < ActiveRecord::Migration[5.1]
  def change
    create_table :importer_checksums do |t|
      t.string :path
      t.string :value
      t.string :algorithm, default: 'SHA1'

      t.timestamps

      t.index :path
    end
  end
end
