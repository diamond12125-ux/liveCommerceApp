import axios from 'axios';

const API_URL = `${import.meta.env.VITE_BACKEND_URL}/api`;

const api = axios.create({
  baseURL: API_URL,
});

// Add token to requests if available
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Handle 401 errors (unauthorized) - redirect to login
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('seller');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const authService = {
  sendOTP: (phone: string) => api.post('/auth/send-otp', { phone }),
  verifyOTP: (phone: string, otp: string) => api.post('/auth/verify-otp', { phone, otp }),
  getMe: () => api.get('/auth/me'),
  logout: () => api.post('/auth/logout'),
};

export const sareeService = {
  getAll: () => api.get('/sarees/'),
  getOne: (id: string | number) => api.get(`/sarees/${id}`),
  create: (data: any) => api.post('/sarees/', data),
  update: (id: string | number, data: any) => api.put(`/sarees/${id}`, data),
  delete: (id: string | number) => api.delete(`/sarees/${id}`),
};

export const liveService = {
  getSessions: () => api.get('/live/sessions/'),
  createSession: (data: any) => api.post('/live/sessions/', data),
  endSession: (id: string | number) => api.post(`/live/sessions/${id}/end`),
  pinSaree: (sessionId: string | number, sareeCode: string) => api.post(`/live/sessions/${sessionId}/pin`, null, { params: { saree_code: sareeCode } }),
  getComments: (sessionId: string | number) => api.get(`/live/sessions/${sessionId}/comments`),
};

export const orderService = {
  getAll: (status?: string) => api.get('/orders/', { params: { status } }),
  getOne: (orderId: string | number) => api.get(`/orders/${orderId}`),
  create: (data: any, sessionId?: string | number) => api.post('/orders/', data, { params: { live_session_id: sessionId } }),
  updateStatus: (orderId: string | number, status: string) => api.put(`/orders/${orderId}/status`, null, { params: { order_status: status } }),
  getMessages: (orderId: string | number) => api.get(`/orders/${orderId}/messages`),
  getPayment: (orderId: string | number) => api.get(`/orders/${orderId}/payment`),
};

export const paymentService = {
  createPaymentLink: (orderId: string | number, gateway = 'razorpay') => api.post(`/payments/create-payment-link/${orderId}`, null, { params: { gateway } }),
  getTransactions: () => api.get('/payments/transactions'),
};

export const whatsappService = {
  getMessages: (orderId: string | number) => api.get(`/orders/${orderId}/messages`),
};

export default api;
