# encoding : utf-8

Sequel.migration do
  up do
    create_table(:Headers) do
      primary_key :id
      String :header, unique: true
      Date :date
    end
  end

  down do
    drop_table(:Headers)
  end
end
