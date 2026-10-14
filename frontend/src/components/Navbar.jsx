import { Bot, LogOut } from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Navbar() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  if (!user) return null

  function handleLogout() {
    logout()
    navigate('/login')
  }

  return (
    <nav className="navbar">
      <Link to="/" className="navbar-brand">
        <span className="navbar-brand-mark">
          <Bot />
        </span>
        Destek Botu Platformu
      </Link>
      <div className="navbar-user">
        <span className="navbar-user-name">{user.email}</span>
        <button className="btn btn-small btn-ghost" onClick={handleLogout}>
          <LogOut />
          Çıkış
        </button>
      </div>
    </nav>
  )
}
