import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const MAILERSEND_API_KEY = process.env.MAILERSEND_API_KEY;
const FROM_EMAIL = process.env.FROM_EMAIL;
const FROM_NAME = process.env.FROM_NAME;

app.post('/api/notificar-cita', async(req, res) => {
    try {
        const { email, persona, puntoVacunacion, fecha } = req.body;

        if (!email || !persona || !puntoVacunacion || !fecha) {
            return res.status(400).json({ error: 'Faltan campos requeridos' });
        }

        const fechaObj = new Date(fecha);
        const fechaFormateada = fechaObj.toLocaleString('es-CL', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
        });

        const response = await fetch('https://api.mailersend.com/v1/email', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${MAILERSEND_API_KEY}`,
            },
            body: JSON.stringify({
                from: { email: FROM_EMAIL, name: FROM_NAME },
                to: [{ email, name: persona }],
                subject: 'Confirmación de tu cita de vacunación',
                text: `Hola ${persona}, tu cita en ${puntoVacunacion} está confirmada para el ${fechaFormateada}.`,
                html: `<p>Hola <b>${persona}</b>,</p><p>Tu cita en <b>${puntoVacunacion}</b> está confirmada para el <b>${fechaFormateada}</b>.</p>`,
            }),
        });

        if (response.status === 202) {
            console.log(`Correo enviado a ${email}`);
            return res.status(200).json({ ok: true });
        } else {
            const errorBody = await response.text();
            console.error('Error MailerSend:', errorBody);
            return res.status(502).json({ error: 'Error al enviar correo', detalle: errorBody });
        }
    } catch (err) {
        console.error('Error de conexión:', err);
        return res.status(500).json({ error: 'Error interno del servidor' });
    }
});

app.listen(process.env.PORT || 3000, () => {
    console.log(`Backend corriendo en http://localhost:${process.env.PORT || 3000}`);
});