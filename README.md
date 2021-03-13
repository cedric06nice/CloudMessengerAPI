# CloudMessengerAPI
### Défi de PurpleGirafe - Mars 2021

API sous Vapor/Swift

### Personalisation:

```
struct Secrets {
    struct Server {
        static let hostname = [String]
        static let port = [Int]
    }
    struct MySQL {
        static let hostname = [String]
        static let username = [String]
        static let password = [String]
        static let database = [String]
    }
}
```

### Routes:

```
POST /users/signup
```
email, name, password -> token, user(id, name, createdAt)

```
POST /users/login
```
name, password -> token, user(id, name, createdAt)

```
GET /users/all-users
```
Bearer (token) -> [ id, name, createdAt ]

```
GET  /users/me
```
Bearer (token) -> id, name, email, passwordHash, createdAt

```
POST /messages/new-message
```
Bearer (token) + subject, owner(id, name) -> id, timestamp, subject, owner(id)

```
GET /messages/all-messages
```
Bearer (token) -> [ id, subject, owner(id), timestamp ]
