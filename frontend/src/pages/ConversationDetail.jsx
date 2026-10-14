import { Bot, User } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import client from '../api/client'

export default function ConversationDetail() {
  const { id: chatbotId, conversationId } = useParams()
  const [conversation, setConversation] = useState(null)

  useEffect(() => {
    client
      .get(`/api/chatbots/${chatbotId}/conversations/${conversationId}`)
      .then((res) => setConversation(res.data))
  }, [chatbotId, conversationId])

  return (
    <div className="page">
      <Link to={`/chatbots/${chatbotId}`} className="back-link">
        ← Bota dön
      </Link>

      <h1>Konuşma</h1>
      {conversation && <p className="muted small">Ziyaretçi: {conversation.visitor_id}</p>}

      {!conversation && (
        <div className="loading-row">
          <div className="spinner" />
          Yükleniyor...
        </div>
      )}

      <div className="chat-widget-messages chat-widget-messages-static">
        {conversation?.messages.map((m) => (
          <div key={m.id} className={`chat-bubble chat-bubble-${m.role}`}>
            <span className="chat-bubble-icon">{m.role === 'user' ? <User /> : <Bot />}</span>
            <div>
              <div>{m.content}</div>
              {m.sources?.length > 0 && (
                <div className="chat-bubble-sources">Kaynak: {m.sources.join(', ')}</div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
