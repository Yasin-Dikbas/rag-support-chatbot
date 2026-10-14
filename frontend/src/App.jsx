import { BrowserRouter, Route, Routes, useLocation } from 'react-router-dom'
import Navbar from './components/Navbar'
import ProtectedRoute from './components/ProtectedRoute'
import { AuthProvider } from './context/AuthContext'
import ChatbotDetail from './pages/ChatbotDetail'
import ConversationDetail from './pages/ConversationDetail'
import Dashboard from './pages/Dashboard'
import Login from './pages/Login'
import Register from './pages/Register'
import Widget from './pages/Widget'

function Chrome({ children }) {
  const location = useLocation()
  const isWidget = location.pathname.startsWith('/widget/')
  return (
    <>
      {!isWidget && <Navbar />}
      {children}
    </>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Chrome>
          <Routes>
            <Route path="/widget/:widgetKey" element={<Widget />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route element={<ProtectedRoute />}>
              <Route path="/" element={<Dashboard />} />
              <Route path="/chatbots/:id" element={<ChatbotDetail />} />
              <Route path="/chatbots/:id/conversations/:conversationId" element={<ConversationDetail />} />
            </Route>
          </Routes>
        </Chrome>
      </AuthProvider>
    </BrowserRouter>
  )
}
