import { FileUp, Type } from 'lucide-react'
import { useState } from 'react'
import client from '../api/client'

export default function DocumentUploadForm({ chatbotId, onUploaded }) {
  const [mode, setMode] = useState('file')
  const [title, setTitle] = useState('')
  const [text, setText] = useState('')
  const [file, setFile] = useState(null)
  const [error, setError] = useState(null)
  const [uploading, setUploading] = useState(false)

  async function handleSubmit(e) {
    e.preventDefault()
    setError(null)

    const form = new FormData()
    if (title) form.append('title', title)

    if (mode === 'file') {
      if (!file) {
        setError('Bir dosya seç.')
        return
      }
      form.append('file', file)
    } else {
      if (!text.trim()) {
        setError('Yapıştırılacak metni gir.')
        return
      }
      form.append('source_text', text)
    }

    setUploading(true)
    try {
      const res = await client.post(`/api/chatbots/${chatbotId}/documents`, form)
      onUploaded(res.data)
      setTitle('')
      setText('')
      setFile(null)
      e.target.reset()
    } catch (err) {
      setError(err.response?.data?.errors?.join(', ') || 'Yükleme başarısız oldu.')
    } finally {
      setUploading(false)
    }
  }

  return (
    <form className="card" onSubmit={handleSubmit}>
      <div className="tab-switch">
        <button type="button" className={mode === 'file' ? 'is-active' : ''} onClick={() => setMode('file')}>
          <FileUp /> Dosya yükle
        </button>
        <button type="button" className={mode === 'text' ? 'is-active' : ''} onClick={() => setMode('text')}>
          <Type /> Metin yapıştır
        </button>
      </div>

      {error && <div className="form-error">{error}</div>}

      <div className="field">
        <label htmlFor="doc-title">Başlık (opsiyonel)</label>
        <input
          id="doc-title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="örn. İade Politikası"
        />
      </div>

      {mode === 'file' ? (
        <div className="field">
          <label htmlFor="doc-file">Dosya (PDF, Markdown veya metin — max 15MB)</label>
          <input
            id="doc-file"
            type="file"
            accept=".pdf,.md,.markdown,.txt,application/pdf,text/markdown,text/plain"
            onChange={(e) => setFile(e.target.files[0] || null)}
          />
        </div>
      ) : (
        <div className="field">
          <label htmlFor="doc-text">Metin</label>
          <textarea
            id="doc-text"
            rows={6}
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="SSS, politika metni veya herhangi bir dokümanı buraya yapıştır..."
          />
        </div>
      )}

      <button className="btn btn-primary" type="submit" disabled={uploading}>
        {uploading ? 'Yükleniyor...' : 'Dokümanı Ekle'}
      </button>
    </form>
  )
}
