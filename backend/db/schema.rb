# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_01_000007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chatbots", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "welcome_message", default: "Merhaba! Size nasıl yardımcı olabilirim?"
    t.string "widget_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_chatbots_on_user_id"
    t.index ["widget_key"], name: "index_chatbots_on_widget_key", unique: true
  end

  create_table "chunks", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "chatbot_id", null: false
    t.integer "chunk_index", null: false
    t.text "content", null: false
    t.float "embedding", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chatbot_id"], name: "index_chunks_on_chatbot_id"
    t.index ["document_id"], name: "index_chunks_on_document_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "chatbot_id", null: false
    t.string "visitor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chatbot_id", "visitor_id"], name: "index_conversations_on_chatbot_id_and_visitor_id"
    t.index ["chatbot_id"], name: "index_conversations_on_chatbot_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "chatbot_id", null: false
    t.string "title", null: false
    t.string "source_type", default: "file", null: false
    t.string "status", default: "pending", null: false
    t.text "source_text"
    t.text "raw_text"
    t.text "error_message"
    t.integer "char_count"
    t.integer "chunk_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chatbot_id"], name: "index_documents_on_chatbot_id"
    t.index ["status"], name: "index_documents_on_status"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "role", null: false
    t.text "content", null: false
    t.jsonb "sources", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chatbots", "users"
  add_foreign_key "chunks", "chatbots"
  add_foreign_key "chunks", "documents"
  add_foreign_key "conversations", "chatbots"
  add_foreign_key "documents", "chatbots"
  add_foreign_key "messages", "conversations"
end
