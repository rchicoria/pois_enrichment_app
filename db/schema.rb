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

ActiveRecord::Schema.define(:version => 20130111053539) do

  create_table "categoria", :force => true do |t|
    t.string   "nome"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "count"
  end

  create_table "life_cooler_pois", :force => true do |t|
    t.string   "nome_lc"
    t.string   "url_imagem"
    t.string   "categoria_lc"
    t.string   "subcategoria_lc"
    t.string   "municipio_lc"
    t.string   "distrito_lc"
    t.text     "descricao_lc"
    t.string   "telefone"
    t.string   "website"
    t.string   "horario"
    t.text     "especialidades_lc"
    t.string   "tipo_restaurante_lc"
    t.string   "preco_medio"
    t.string   "lotacao"
    t.string   "tipo_musica_lc"
    t.string   "ano_construcao"
    t.string   "servicos_cultura_lc"
    t.boolean  "bandeira_azul"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "street"
    t.string   "url"
  end

  create_table "locais", :force => true do |t|
    t.string  "nome"
    t.string  "url_imagem"
    t.string  "lat"
    t.string  "lng"
    t.string  "type"
    t.integer "municipio"
    t.integer "distrito"
    t.text    "descricao"
    t.string  "telefone"
    t.string  "website"
    t.string  "horario"
    t.text    "especialidades"
    t.string  "tipo_restaurante"
    t.string  "preco_medio"
    t.string  "lotacao"
    t.string  "tipo_musica"
    t.string  "ano_construcao"
    t.string  "servicos_cultura"
    t.boolean "bandeira_azul"
    t.integer "checkins"
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
