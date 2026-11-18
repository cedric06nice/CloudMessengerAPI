# CloudMessengerAPI

The back end of a group messaging app: a REST and WebSocket API in Swift with [Vapor 4](https://vapor.codes) and Fluent (MySQL in production, SQLite locally). Its client is [PGMessengerApp](https://github.com/cedric06nice/PGMessengerApp).

Built in March–April 2021 as a team challenge for [Purple Giraffe](https://www.purplegiraffe.fr), an online school for mobile development, with Nicolas Picot and Quentin Rolland.

## What I built

- The project setup, database models and migrations.
- Sign-up and login with hashed passwords and expiring bearer tokens, input validation, and duplicate name and email checks.
- The messages model and routes, picture messages, and moderation: moderator accounts, flagging users and messages, unflagging and deleting.

Nicolas built the real-time WebSocket channel and message reporting; Quentin worked on configuration and fixes.

## Routes

Every route except sign-up and login needs `Authorization: Bearer <token>`.

| Method | Route | Does |
| --- | --- | --- |
| POST | `/users/signup` | Create an account (email, name, password) → token and user |
| POST | `/users/login` | Log in with name and password (Basic auth) → token and user |
| GET | `/users/me` | The logged-in user |
| GET | `/users/all-users` | Public list of users |
| POST | `/messages/new-message` | Post a message |
| GET | `/messages/all-messages` | All messages, newest first |
| POST | `/messages/report-message` | Report a message to moderators |
| POST | `/messages/unflag-message` | Moderators: clear a flag |
| POST | `/messages/delete-message` | Moderators: delete a message |
| WS | `/messages/message-web-socket` | Receive new messages in real time |
| POST | `/photos/upload-picture` | Upload a picture for a message |
| GET | `/photos/get-picture` | Download a picture |

## Run it

Fill in `Sources/App/Helpers/Secrets.swift` with your server and database settings (the committed copy holds empty placeholders; keep your real values out of Git):

```swift
struct Secrets {
    struct Server {
        static let hostname = "127.0.0.1"
        static let port = 8080
    }
    struct MySQL {
        static let hostname = "localhost"
        static let username = "vapor"
        static let password = "password"
        static let database = "cloudmessenger"
    }
}
```

```sh
swift run Run serve
```

Migrations run automatically on start.

---

Cedric Pugnaire · Software Developer · [cedric06nice.com](https://cedric06nice.com) · [CV](https://cedric06nice.com/cv) · [GitHub](https://github.com/cedric06nice)
