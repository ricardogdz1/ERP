import axios from 'axios';

const api = axios.create({
  baseURL: 'http://192.168.7.7:3000', // teu IP local com o backend rodando
});

export default api;
