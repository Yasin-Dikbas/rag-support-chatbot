import { Check, Code2, MessageSquare, RotateCw, Trash2 } from 'lucide-react'
import { useCallback, useEffect, useRef, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import client from '../api/client'
import ChatWidget from '../components/ChatWidget'
import DocumentUploadForm from '../components/DocumentUploadForm'
import StatusBadge from '../components/StatusBadge'

const POLL_STATUSES = new Set(['pending', 'processing'])

export default function ChatbotDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const [chatbot, setChatbot] = useState(null)
  const [documents, setDocuments] = useState(null)
  const [conversations, setConversations] = useState(null)
  const [copied, setCopied] = useState(false)
  const pollRef = useRef(null)

  const loadChatbot = useCallback(() => {
    client.get(`/api/chatbots/${id}`).then((res) => setChatbot(res.data))
  }, [id])

  const loadDocuments = useCallback(() => {
    client.get(`/api/chatbots/${id}/documents`).then((res) => setDocuments(res.data))
  }, [id])

  useEffect(() => {
    loadChatbot()
    loadDocuments()
    client.get(`/api/chatbots/${id}/conversations`).then((res) => setConversations(res.data))
  }, [id, loadChatbot, loadDocuments])

  useEffect(() => {
    const hasPending = documents?.some((d) => POLL_STATUSES.has(d.status))
    if (!hasPending) return

    pollRef.current = setInterval(() => {
      loadDocuments()
      loadChatbot()
    }, 3000)
    return () => clearInterval(pollRef.current)
  }, [documents, loadDocuments, loadChatbot])

  async function handleDeleteDocument(docId) {
    if (!confirm('Bu dokümanı silmek istediğine emin misin?')) return
    await client.delete(`/api/chatbots/${id}/documents/${docId}`)
    loadDocuments()
    loadChatbot()
  }

  async function handleRetryDocument(docId) {
    await client.post(`/api/chatbots/${id}/documents/${docId}/retry`)
    loadDocuments()
  }

  async function handleDeleteChatbot() {
    if (!confirm('Bu botu ve tüm dokümanlarını kalıcı olarak silmek istediğine emin misin?')) return
    await client.delete(`/api/chatbots/${id}`)
    navigate('/')
  }

  function handleCopySnippet() {
    navigator.clipboard.writeText(snippet)
    setCopied(true)
    setTimeout(() => setCopied(false), 1800)
  }

  if (!chatbot) {
    return (
      <div className="page">
        <div className="loading-row">
          <div className="spinner" />
          Yükleniyor...
        </div>
      </div>
    )
  }

  const snippet = `<script src="${window.location.origin}/widget.js" data-widget-key="${chatbot.widget_key}" async></script>`

  return (
    <div className="page">
      <Link to="/" className="back-link">
        ← Botlara dön
      </Link>

      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 16 }}>
        <div>
          <h1>{chatbot.name}</h1>
          <p className="muted">{chatbot.description || 'Açıklama eklenmemiş'}</p>
        </div>
        <button className="btn btn-small btn-danger-ghost" onClick={handleDeleteChatbot}>
          <Trash2 />
          Botu Sil
        </button>
      </div>

      <div className="stat-tiles">
        <div className="stat-tile">
          <div className="stat-tile-label">Doküman</div>
          <div className="stat-tile-value">
            {chatbot.completed_documents_count}/{chatbot.documents_count}
          </div>
        </div>
        <div className="stat-tile">
          <div className="stat-tile-label">Parça (chunk)</div>
          <div className="stat-tile-value">{chatbot.chunks_count}</div>
        </div>
        <div className="stat-tile">
          <div className="stat-tile-label">Konuşma</div>
          <div className="stat-tile-value">{chatbot.conversations_count}</div>
        </div>
      </div>

      <h2>
        <Code2 size={17} style={{ verticalAlign: -3, marginRight: 6 }} />
        Siteye Göm
      </h2>
      <div className="card">
        <p className="muted small">
          Bu kodu herhangi bir web sitesinin HTML'ine ekle — sağ altta açılır bir sohbet balonu belirir.
        </p>
        <div className="code-snippet">
          <code>{snippet}</code>
          <button className="btn btn-small btn-ghost" onClick={handleCopySnippet}>
            {copied ? <Check /> : <Code2 />}
            {copied ? 'Kopyalandı' : 'Kopyala'}
          </button>
        </div>
      </div>

      <div className="detail-columns">
        <div>
          <h2>Dokümanlar</h2>
          <DocumentUploadForm chatbotId={id} onUploaded={() => loadDocuments()} />

          {documents?.length === 0 && (
            <div className="empty-state">
              <strong>Henüz doküman yok</strong>
              <span className="small">Bot soruları yanıtlayabilmek için en az bir doküman gerekir.</span>
            </div>
          )}

          <ul className="receipt-list">
            {documents?.map((doc) => (
              <li key={doc.id} className="receipt-row" style={{ cursor: 'default' }}>
                <div className="receipt-main">
                  <div>
                    <div className="receipt-merchant">{doc.title}</div>
                    <div className="receipt-meta">
                      {doc.chunk_count > 0 ? `${doc.chunk_count} parça` : doc.source_type === 'file' ? 'Dosya' : 'Metin'}
                      {doc.error_message && ` · ${doc.error_message}`}
                    </div>
                  </div>
                </div>
                <div className="receipt-actions">
                  <StatusBadge status={doc.status} />
                  {doc.status === 'failed' && (
                    <button className="btn btn-small btn-ghost" onClick={() => handleRetryDocument(doc.id)}>
                      <RotateCw />
                    </button>
                  )}
                  <button className="btn btn-small btn-danger-ghost" onClick={() => handleDeleteDocument(doc.id)}>
                    <Trash2 />
                  </button>
                </div>
              </li>
            ))}
          </ul>
        </div>

        <div>
          <h2>Botu Dene</h2>
          <ChatWidget widgetKey={chatbot.widget_key} className="chat-widget-preview" />
        </div>
      </div>

      <h2>
        <MessageSquare size={17} style={{ verticalAlign: -3, marginRight: 6 }} />
        Son Konuşmalar
      </h2>
      {conversations?.length === 0 && <p className="muted small">Henüz bir ziyaretçi bu botla konuşmadı.</p>}
      <ul className="receipt-list">
        {conversations?.map((c) => (
          <li key={c.id}>
            <Link to={`/chatbots/${id}/conversations/${c.id}`} className="receipt-row">
              <div className="receipt-main">
                <div style={{ minWidth: 0 }}>
                  <div className="receipt-merchant">{c.last_message}</div>
                  <div className="receipt-meta">
                    {c.message_count} mesaj · {new Date(c.updated_at).toLocaleString('tr-TR')}
                  </div>
                </div>
              </div>
            </Link>
          </li>
        ))}
      </ul>
    </div>
  )
}
