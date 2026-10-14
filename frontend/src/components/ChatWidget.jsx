import { Bot, Send, User } from 'lucide-react'
import { useEffect, useRef, useState } from 'react'
import widgetClient from '../api/widgetClient'

function visitorStorageKey(widgetKey) {
  return `rag-widget:${widgetKey}:visitor`
}

function conversationStorageKey(widgetKey) {
  return `rag-widget:${widgetKey}:conversation`
}

function getOrCreateVisitorId(widgetKey) {
  const key = visitorStorageKey(widgetKey)
  let id = localStorage.getItem(key)
  if (!id) {
    id = crypto.randomUUID()
    localStorage.setItem(key, id)
  }
  return id
}

export default function ChatWidget({ widgetKey, className = '' }) {
  const [info, setInfo] = useState(null)
  const [messages, setMessages] = useState([])
  const [input, setInput] = useState('')
  const [sending, setSending] = useState(false)
  const [error, setError] = useState(null)
  const conversationIdRef = useRef(localStorage.getItem(conversationStorageKey(widgetKey)) || null)
  const visitorIdRef = useRef(getOrCreateVisitorId(widgetKey))
  const scrollRef = useRef(null)

  useEffect(() => {
    widgetClient.get(`/api/widget/${widgetKey}`).then((res) => setInfo(res.data))
  }, [widgetKey])

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: 'smooth' })
  }, [messages, sending])

  async function handleSend(e) {
    e.preventDefault()
    const text = input.trim()
    if (!text || sending) return

    setMessages((prev) => [...prev, { role: 'user', content: text }])
    setInput('')
    setSending(true)
    setError(null)

    try {
      const res = await widgetClient.post(`/api/widget/${widgetKey}/messages`, {
        message: text,
        visitor_id: visitorIdRef.current,
        conversation_id: conversationIdRef.current
      })
      conversationIdRef.current = res.data.conversation_id
      localStorage.setItem(conversationStorageKey(widgetKey), String(res.data.conversation_id))
      setMessages((prev) => [...prev, { role: 'assistant', content: res.data.answer, sources: res.data.sources }])
    } catch (err) {
      setError(err.response?.data?.error || 'Mesaj gönderilemedi, lütfen tekrar deneyin.')
    } finally {
      setSending(false)
    }
  }

  return (
    <div className={`chat-widget ${className}`}>
      <div className="chat-widget-header">
        <span className="chat-widget-header-icon">
          <Bot />
        </span>
        <strong>{info?.name || 'Destek Botu'}</strong>
      </div>

      <div className="chat-widget-messages" ref={scrollRef}>
        {messages.length === 0 && info && (
          <div className="chat-bubble chat-bubble-assistant">{info.welcome_message}</div>
        )}
        {messages.map((m, i) => (
          <div key={i} className={`chat-bubble chat-bubble-${m.role}`}>
            <span className="chat-bubble-icon">{m.role === 'user' ? <User /> : <Bot />}</span>
            <div>
              <div>{m.content}</div>
              {m.sources?.length > 0 && (
                <div className="chat-bubble-sources">Kaynak: {m.sources.join(', ')}</div>
              )}
            </div>
          </div>
        ))}
        {sending && (
          <div className="chat-bubble chat-bubble-assistant">
            <span className="chat-bubble-icon">
              <Bot />
            </span>
            <div className="spinner" />
          </div>
        )}
      </div>

      {error && <div className="form-error chat-widget-error">{error}</div>}

      <form className="chat-widget-input" onSubmit={handleSend}>
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Bir soru yaz..."
          disabled={sending}
        />
        <button className="btn btn-primary btn-small" type="submit" disabled={sending || !input.trim()}>
          <Send />
        </button>
      </form>
    </div>
  )
}
