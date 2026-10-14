import { Bot, Plus } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import client from '../api/client'

export default function Dashboard() {
  const [chatbots, setChatbots] = useState(null)
  const [showForm, setShowForm] = useState(false)
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [error, setError] = useState(null)
  const [creating, setCreating] = useState(false)

  useEffect(() => {
    client.get('/api/chatbots').then((res) => setChatbots(res.data))
  }, [])

  async function handleCreate(e) {
    e.preventDefault()
    setError(null)
    setCreating(true)
    try {
      const res = await client.post('/api/chatbots', { name, description })
      setChatbots((prev) => [res.data, ...prev])
      setName('')
      setDescription('')
      setShowForm(false)
    } catch (err) {
      setError(err.response?.data?.errors?.join(', ') || 'Bot oluşturulamadı.')
    } finally {
      setCreating(false)
    }
  }

  return (
    <div className="page">
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 16 }}>
        <div>
          <h1>Destek Botların</h1>
          <p className="muted">Her bot, kendi dokümanlarına dayanarak soruları yanıtlayan ayrı bir asistandır.</p>
        </div>
        <button className="btn btn-primary" onClick={() => setShowForm((v) => !v)}>
          <Plus />
          Yeni Bot
        </button>
      </div>

      {showForm && (
        <div className="card" style={{ marginTop: 20 }}>
          {error && <div className="form-error">{error}</div>}
          <form onSubmit={handleCreate}>
            <div className="field">
              <label htmlFor="name">Bot adı</label>
              <input
                id="name"
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="örn. Müşteri Destek Botu"
              />
            </div>
            <div className="field">
              <label htmlFor="description">Açıklama (opsiyonel)</label>
              <input
                id="description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="örn. Teslimat ve iade politikalarını yanıtlar"
              />
            </div>
            <button className="btn btn-primary" type="submit" disabled={creating}>
              {creating ? 'Oluşturuluyor...' : 'Oluştur'}
            </button>
          </form>
        </div>
      )}

      {chatbots === null && (
        <div className="loading-row" style={{ marginTop: 40 }}>
          <div className="spinner" />
          Yükleniyor...
        </div>
      )}

      {chatbots?.length === 0 && (
        <div className="empty-state">
          <Bot />
          <strong>Henüz bir bot oluşturmadın</strong>
          <span className="small">Başlamak için "Yeni Bot" butonuna tıkla.</span>
        </div>
      )}

      {chatbots?.length > 0 && (
        <div className="chatbot-grid">
          {chatbots.map((bot) => (
            <Link key={bot.id} to={`/chatbots/${bot.id}`} className="chatbot-card">
              <span className="chatbot-card-icon">
                <Bot />
              </span>
              <strong>{bot.name}</strong>
              <p className="muted small chatbot-card-desc">{bot.description || 'Açıklama eklenmemiş'}</p>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}
