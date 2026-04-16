## Installation

```bash
pip install -r requirements.txt
```
## Endpoints

### POST /tasks
Créer une nouvelle tâche

**Body:**
```json
{
  "title": "Write",
  "content": "Prepare lesson",
  "due_date": "2025-09-30",
  "request_timestamp": "2025-09-25T20:00:00Z"
}
```

**Headers:**
- `Authorization: Bearer <token>`
- `correlation_id: abc123`

**Réponse:** Retourne le payload reçu avec un ID généré (201 Created)

### GET /tasks
Lister toutes les tâches (triées par request_timestamp)

**Headers:**
- `Authorization: Bearer <token>`
- `correlation_id: abc124`

**Réponse:** Liste des tâches (200 OK)

### GET /tasks/{id}
Obtenir une tâche spécifique

**Headers:**
- `Authorization: Bearer <token>`
- `correlation_id: abc125`

**Réponse:** La tâche (200 OK) ou 404 Not Found

### PUT /tasks/{id}
Mettre à jour une tâche

**Body:**
```json
{
  "title": "Review",
  "content": "Check slides",
  "done": true,
  "request_timestamp": "2025-09-25T20:01:00Z"
}
```

**Headers:**
- `Authorization: Bearer <token>`
- `correlation_id: abc126`

**Réponse:** Retourne le payload mis à jour (200 OK) ou 409 Conflict si timestamp plus ancien

### DELETE /tasks/{id}
Supprimer une tâche

**Body:**
```json
{
  "request_timestamp": "2025-09-25T20:02:00Z"
}
```

**Headers:**
- `Authorization: Bearer <token>`
- `correlation_id: abc127`

**Réponse:** Retourne la tâche supprimée (200 OK) ou 409 Conflict si timestamp plus ancien

## Codes HTTP

Utilise la classe `StatusCode` :
- `200 OK` → GET/PUT/DELETE réussi
- `201 Created` → POST réussi
- `400 Bad Request` → Corps de requête invalide
- `401 Unauthorized` → Authentification manquante/invalide
- `404 Not Found` → Ressource non trouvée
- `409 Conflict` → Conflit de timestamp/concurrence
- `429 Too Many Requests` → Cluster surchargé (non implémenté pour l'instant)
- `500 Internal Server Error` → Erreur serveur

## Exemple de test

```bash

# Créer une tâche
curl -X POST http://localhost:8080/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -H "correlation_id: test-123" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "content": "Test content",
    "due_date": "2025-12-31",
    "request_timestamp": "2025-01-01T10:00:00Z"
  }'

# Lister les tâches
curl -X GET http://localhost:8080/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -H "correlation_id: test-124"

# With https
curl --cacert ./cert.pem -X POST https://localhost:8080/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -H "correlation_id: test-123" \
  -H "Content-Type: application/json" \
  -d '{ "title":"Test Task", "content":"Test content", "due_date":"2025-12-31", "request_timestamp":"2025-01-01T10:00:00Z" }'
```
