import axios from 'axios'
import { API_URL } from './client'

// Separate, unauthenticated client for the public widget endpoints.
// These run embedded on arbitrary third-party sites, so this must never
// attach a JWT or redirect on 401 like the dashboard client does.
const widgetClient = axios.create({ baseURL: API_URL })

export default widgetClient
