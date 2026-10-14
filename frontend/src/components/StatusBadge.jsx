import { CheckCircle2, Clock, Loader2, XCircle } from 'lucide-react'

const CONFIG = {
  pending: { icon: Clock, label: 'Bekliyor' },
  processing: { icon: Loader2, label: 'İşleniyor' },
  completed: { icon: CheckCircle2, label: 'Tamamlandı' },
  failed: { icon: XCircle, label: 'Başarısız' }
}

export default function StatusBadge({ status }) {
  const { icon: Icon, label } = CONFIG[status] || CONFIG.pending
  return (
    <span className={`status status-${status}`}>
      <Icon />
      {label}
    </span>
  )
}
