const http = require('http');

const PORT = process.env.PORT || 3000;

const htmlContent = `
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hermes - Plataforma GitOps</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #0b0f19;
            --card-bg: rgba(255, 255, 255, 0.03);
            --border-color: rgba(255, 255, 255, 0.08);
            --text-primary: #f3f4f6;
            --text-secondary: #9ca3af;
            --accent-primary: #6366f1;
            --accent-secondary: #a855f7;
            --accent-success: #10b981;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow-x: hidden;
            position: relative;
        }

        /* Background elements */
        .glow-1 {
            position: absolute;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(99, 102, 241, 0.15) 0%, rgba(0,0,0,0) 70%);
            top: -100px;
            left: -100px;
            z-index: 1;
            filter: blur(50px);
        }

        .glow-2 {
            position: absolute;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(168, 85, 247, 0.12) 0%, rgba(0,0,0,0) 70%);
            bottom: -150px;
            right: -150px;
            z-index: 1;
            filter: blur(60px);
        }

        .container {
            z-index: 2;
            width: 100%;
            max-width: 700px;
            padding: 2rem;
        }

        .card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 24px;
            padding: 3rem 2.5rem;
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            text-align: center;
            transition: transform 0.3s ease, border-color 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            border-color: rgba(99, 102, 241, 0.25);
        }

        .logo-container {
            margin-bottom: 2rem;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            width: 80px;
            height: 80px;
            border-radius: 20px;
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            box-shadow: 0 8px 24px rgba(99, 102, 241, 0.3);
        }

        .logo-icon {
            font-size: 2.5rem;
            color: white;
            animation: pulse 3s infinite ease-in-out;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 0.9; }
            50% { transform: scale(1.08); opacity: 1; }
        }

        h1 {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 0.75rem;
            background: linear-gradient(to right, #ffffff, #c7d2fe, #e9d5ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: -0.5px;
        }

        .subtitle {
            color: var(--text-secondary);
            font-size: 1.1rem;
            line-height: 1.6;
            margin-bottom: 2.5rem;
            font-weight: 300;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            border-radius: 9999px;
            background: rgba(16, 185, 129, 0.08);
            border: 1px solid rgba(16, 185, 129, 0.2);
            color: var(--accent-success);
            font-weight: 600;
            font-size: 0.875rem;
            margin-bottom: 2.5rem;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: var(--accent-success);
            box-shadow: 0 0 10px var(--accent-success);
            animation: blink 1.5s infinite;
        }

        @keyframes blink {
            0%, 100% { opacity: 0.5; }
            50% { opacity: 1; }
        }

        .details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            text-align: left;
            margin-bottom: 2rem;
        }

        .detail-item {
            background: rgba(255, 255, 255, 0.015);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 1.25rem;
        }

        .detail-title {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--text-secondary);
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .detail-value {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        .footer {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-top: 1.5rem;
            border-top: 1px solid var(--border-color);
            padding-top: 1.5rem;
        }

        .footer a {
            color: var(--accent-primary);
            text-decoration: none;
            transition: color 0.2s;
        }

        .footer a:hover {
            color: var(--accent-secondary);
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="glow-1"></div>
    <div class="glow-2"></div>

    <div class="container">
        <div class="card">
            <div class="logo-container">
                <!-- SVG Winged sandal or wings representing Hermes -->
                <span class="logo-icon">⚡</span>
            </div>
            <h1>Hermes OS</h1>
            <p class="subtitle">Sua infraestrutura local de GitOps foi provisionada e sincronizada com absoluto sucesso.</p>
            
            <div class="status-badge">
                <span class="status-dot"></span>
                Sincronizado via ArgoCD
            </div>

            <div class="details-grid">
                <div class="detail-item">
                    <div class="detail-title">Cluster Local</div>
                    <div class="detail-value">K3d (dev-cluster)</div>
                </div>
                <div class="detail-item">
                    <div class="detail-title">Motor GitOps</div>
                    <div class="detail-value">ArgoCD 🐙</div>
                </div>
                <div class="detail-item">
                    <div class="detail-title">Ambiente</div>
                    <div class="detail-value">Development</div>
                </div>
                <div class="detail-item">
                    <div class="detail-title">Status da Ingress</div>
                    <div class="detail-value">Roteamento Ativo</div>
                </div>
            </div>

            <div class="footer">
                Desenvolvido com 💜 pelo SRE Bot &bull; <a href="https://argoproj.github.io/argo-cd/" target="_blank">Documentação ArgoCD</a>
            </div>
        </div>
    </div>
</body>
</html>
`;

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.end(htmlContent);
});

server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
