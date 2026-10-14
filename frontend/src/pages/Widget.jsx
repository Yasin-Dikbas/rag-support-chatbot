import { useParams } from 'react-router-dom'
import ChatWidget from '../components/ChatWidget'

// Rendered inside the <iframe> that widget.js injects into a third-party
// page. No navbar, no auth — just the chat UI, sized to fill the iframe.
export default function Widget() {
  const { widgetKey } = useParams()
  return (
    <div className="widget-page">
      <ChatWidget widgetKey={widgetKey} className="chat-widget-fill" />
    </div>
  )
}
