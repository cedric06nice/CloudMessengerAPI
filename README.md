# CloudMessengerAPI

The back end of **PG Messenger**, a group chat published on the App Store and Google Play: a REST and WebSocket API in Swift with [Vapor 4](https://vapor.codes) and Fluent (MySQL in production, SQLite locally).

Built in 2021 by a team of four as a challenge for [Purple Giraffe](https://www.purplegiraffe.fr), an online school for mobile development. The main client is the [Flutter app](https://github.com/QuentinDeviOS/pg_messenger); I also wrote a [SwiftUI prototype client](https://github.com/cedric06nice/PGMessengerApp).

## What I built

- The project setup, database models and migrations.
- Sign-up and login with hashed passwords and expiring bearer tokens, input validation, and duplicate name and email checks.
- The messages model and routes, picture messages, and moderation: moderator accounts, flagging users and messages, unflagging and deleting.

In the Flutter app I built the moderation tools, password change, English/French translation, the app icon and splash screen, and the release builds.

On the API, Nicolas Picot built the real-time WebSocket channel and message reporting, and Quentin Rolland worked on configuration and fixes.

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
