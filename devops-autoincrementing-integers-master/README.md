# DevOps Auto-incrementing Integers Application

This is a containerized Rails application that implements an auto-incrementing integers API with comprehensive DevOps tooling including HTTPS, monitoring, logging, and proxy layer features.

## Features

- **Containerized Rails Application**: Production-ready Docker image
- **HTTPS Support**: SSL/TLS encryption with self-signed certificates
- **Proxy Layer**: Nginx with authentication, rate limiting, and caching
- **Monitoring**: Prometheus metrics collection and Grafana visualization
- **Logging**: Fluent-bit log forwarding to external endpoints
- **Database**: PostgreSQL with Redis caching
- **Health Checks**: Application and infrastructure health monitoring

## Architecture

```
Internet → Nginx (HTTPS) → Rails App → PostgreSQL
                ↓              ↓         ↓
            Prometheus    Fluent-bit   Redis
                ↓              ↓
            Grafana      External Logs
```

## Prerequisites

- Docker and Docker Compose
- OpenSSL (for certificate generation)
- htpasswd utility (for authentication)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd devops-autoincrementing-integers-master
```

### 2. Generate SSL Certificates and Authentication

```bash
# Generate SSL certificate (already done in setup)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/server.key \
  -out nginx/ssl/server.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Create authentication file (already done in setup)
htpasswd -cb nginx/auth/.htpasswd admin admin123
```

### 3. Start the Application

```bash
# Build and start all services
docker-compose up --build

# Or run in background
docker-compose up -d --build
```

### 4. Access the Application

- **Application**: https://localhost (redirects to HTTPS)
- **API Documentation**: https://localhost/api/v1/
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001 (admin/admin)
- **Health Check**: https://localhost/health

## API Usage

### 1. Create User
```bash
curl -X POST https://localhost/users/create \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123"}' \
  -k
```

### 2. Get Integer (requires authentication)
```bash
curl -X GET https://localhost/api/v1/integer \
  -H "Authorization: Basic YWRtaW46YWRtaW4xMjM=" \
  -k
```

### 3. Increment Integer
```bash
curl -X PUT https://localhost/api/v1/integer/increment \
  -H "Authorization: Basic YWRtaW46YWRtaW4xMjM=" \
  -k
```

### 4. Update Integer
```bash
curl -X PUT https://localhost/api/v1/integer \
  -H "Authorization: Basic YWRtaW46YWRtaW4xMjM=" \
  -H "Content-Type: application/json" \
  -d '{"value": 42}' \
  -k
```

### 5. Get Metrics
```bash
curl https://localhost/metrics -k
```

## Configuration

### Environment Variables

The application uses the following environment variables:

- `RAILS_ENV`: Application environment (development/production)
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `RAILS_LOG_TO_STDOUT`: Enable logging to stdout

### Nginx Configuration

- **Rate Limiting**: Configured per endpoint type
- **Authentication**: Basic auth for API endpoints
- **SSL**: TLS 1.2+ with strong ciphers
- **Caching**: GET requests cached for 1 minute

### Prometheus Configuration

- **Scrape Interval**: 15 seconds
- **Targets**: Rails app, Nginx, Prometheus itself
- **Metrics**: HTTP requests, response times, errors

### Fluent-bit Configuration

- **Input**: Rails and Nginx logs
- **Output**: External HTTPS endpoint
- **Parsing**: Structured log parsing
- **Filtering**: Add metadata and timestamps

## Monitoring and Observability

### Key Metrics

- **Application**: Request rate, response time, error rate
- **Infrastructure**: CPU, memory, disk usage
- **Database**: Connection count, query performance
- **Proxy**: Nginx request rate, response time

### Dashboards

Grafana comes pre-configured with:
- Application performance overview
- Infrastructure health monitoring
- Error rate and response time trends
- Database and cache performance

### Alerting

Prometheus alerting rules for:
- High error rates
- Slow response times
- Service unavailability
- Resource exhaustion

## Development

### Running Tests

```bash
# Run tests in container
docker-compose exec rails-app bundle exec rspec

# Run specific test file
docker-compose exec rails-app bundle exec rspec spec/models/user_spec.rb
```

### Database Operations

```bash
# Create database
docker-compose exec rails-app bundle exec rails db:create

# Run migrations
docker-compose exec rails-app bundle exec rails db:migrate

# Seed database
docker-compose exec rails-app bundle exec rails db:seed

# Reset database
docker-compose exec rails-app bundle exec rails db:reset
```

### Rails Console

```bash
# Start Rails console
docker-compose exec rails-app bundle exec rails console

# Start Rails console in specific environment
docker-compose exec rails-app bundle exec rails console -e production
```

## Production Deployment

### Docker Image

The application includes a production-ready Dockerfile with:
- Multi-stage build for optimization
- Non-root user for security
- Health checks
- Proper signal handling

### Infrastructure

See `infrastructure-diagram.md` for detailed production architecture including:
- Load balancer configuration
- Auto-scaling groups
- Multi-AZ deployment
- Security and compliance

### Multi-tenancy

See `multi-tenancy-architecture.md` for SaaS multi-tenant architecture including:
- Database schema changes
- Tenant isolation
- Roll-out plan
- Risk mitigation

## Troubleshooting

### Common Issues

1. **SSL Certificate Errors**
   - Regenerate certificates: `make ssl-certs`
   - Check certificate validity: `openssl x509 -in nginx/ssl/server.crt -text`

2. **Database Connection Issues**
   - Check PostgreSQL logs: `docker-compose logs postgres`
   - Verify connection string in docker-compose.yml

3. **Nginx Configuration Errors**
   - Check Nginx logs: `docker-compose logs nginx`
   - Validate configuration: `docker-compose exec nginx nginx -t`

4. **Prometheus Scraping Issues**
   - Check targets: http://localhost:9090/targets
   - Verify service discovery and labels

### Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs rails-app
docker-compose logs nginx
docker-compose logs prometheus

# Follow logs in real-time
docker-compose logs -f rails-app
```

### Health Checks

```bash
# Application health
curl -k https://localhost/health

# Database health
docker-compose exec postgres pg_isready -U postgres

# Redis health
docker-compose exec redis redis-cli ping
```

## Security

### Authentication

- **API Endpoints**: Basic authentication required
- **Default Credentials**: admin/admin123
- **Rate Limiting**: Per-endpoint and per-IP limits

### SSL/TLS

- **Protocols**: TLS 1.2 and 1.3
- **Ciphers**: Strong cipher suites
- **HSTS**: HTTP Strict Transport Security enabled

### Network Security

- **VPC**: Isolated network environment
- **Security Groups**: Port-level access control
- **Private Subnets**: No direct internet access

## Performance

### Optimization Features

- **Caching**: Redis for session and application data
- **Compression**: Gzip compression enabled
- **Connection Pooling**: Database connection optimization
- **Load Balancing**: Multiple application instances

### Scaling

- **Horizontal**: Add more application containers
- **Vertical**: Increase container resources
- **Database**: Read replicas and connection pooling
- **Cache**: Redis cluster for high availability

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the documentation
- Contact the development team
