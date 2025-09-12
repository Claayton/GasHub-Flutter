# 🚀 GasHub - Sistema de Gestão de Pedidos

Sistema mobile para gestão de pedidos de gás e água, desenvolvido em Flutter.

## 📱 Sobre o Projeto

Sistema para pequenos negócios do ramo de distribuição de gás e água mineral, facilitando o controle de pedidos, clientes e entregas.

## 🛠️ Tecnologias

- **Flutter** 3.35.2
- **Firebase** (Firestore, Auth)
- **Bloc** (Gestão de estado)
- **Android** SDK 34

## 📦 Funcionalidades

- [x] Cadastro de pedidos
- [x] Gestão de clientes  
- [x] Controle de produtos (Gás, Água)
- [x] Diferentes métodos de pagamento
- [x] Dashboard de pedidos
- [ ] Relatórios (em desenvolvimento)

## 🚀 Como Executar

```bash
# Clonar repositório
git clone https://github.com/seuusuario/gashub.git

# Entrar na pasta
cd gashub

# Instalar dependências
flutter pub get

# Executar
flutter run \
  --dart-define=FIREBASE_API_KEY=*sua_api_key* \
  --dart-define=FIREBASE_AUTH_DOMAIN=*seu_auth_domain* \
  --dart-define=FIREBASE_PROJECT_ID=*seu_project_id* \
  --dart-define=FIREBASE_STORAGE_BUCKET=*seu_storage_bucket* \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=*seu_messaging_sender_id* \
  --dart-define=FIREBASE_APP_ID=*seu_app_id* \
  --dart-define=FIREBASE_MEASUREMENT_ID=*seu_measuerement_id*
```

```

  lib/
    ├── config/          # Configurações do projeto
    ├── cubit/           # Lógica de negócio (BLoC)
    ├── models/          # Modelos de dados
    ├── repositories/    # Manipulação de dados (CRUD)
    ├── screens/         # Telas do app
    ├── services/        # Integrações externas
    ├── utils/           # 
    └── widgets/         # Componentes UI

```

## 📋 Versões

- **1.0.0-alpha** - Versão inicial alpha (testes internos)

## 👥 Contribuição

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -m 'Add nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 💬 Contato

Clayton Garcia - [@claayton](https://github.com/claaytong) - claaytongarcia@gmail.com
