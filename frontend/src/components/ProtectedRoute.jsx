import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function ProtectedRoute() {
  const { user, loading } = useAuth()

  if (loading)
    return (
      <div className="centered-page">
        <div className="loading-row">
          <div className="spinner" />
          Yükleniyor...
        </div>
      </div>
    )
  if (!user) return <Navigate to="/login" replace />

  return <Outlet />
}
