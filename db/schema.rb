# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121214054308) do

  create_table "categoria", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "count"
  end

  create_table "locais", :force => true do |t|
    t.string  "nome"
    t.string  "url_imagem"
    t.string  "lat"
    t.string  "lng"
    t.string  "type"
    t.integer "municipio"
    t.integer "distrito"
    t.string  "descricao"
    t.string  "telefone"
    t.string  "website"
    t.string  "horario"
    t.string  "especialidades"
    t.string  "tipo_restaurante"
    t.string  "preco_medio"
    t.string  "lotacao"
    t.string  "tipo_musica"
    t.string  "ano_construcao"
    t.string  "servicos_cultura"
    t.boolean "bandeira_azul"
  end

  create_table "poi_coordinates", :force => true do |t|
    t.string   "name"
    t.string   "lat"
    t.string   "lng"
    t.string   "uri"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "servicos", :force => true do |t|
    t.string   "nome"
    t.integer  "local_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tokens", :force => true do |t|
    t.string   "name"
    t.integer  "freq"
    t.integer  "categoria_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

end
