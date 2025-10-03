const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Maritime Procurement ERP API',
      version: '1.0.0',
      description: 'Comprehensive API for Maritime Procurement ERP System',
      contact: {
        name: 'API Support',
        email: 'support@maritime-procurement.com',
        url: 'https://maritime-procurement.com/support'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },
    servers: [
      {
        url: process.env.NODE_ENV === 'production' 
          ? 'https://api.maritime-procurement.com'
          : `http://localhost:${process.env.PORT || 5000}`,
        description: process.env.NODE_ENV === 'production' ? 'Production server' : 'Development server'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT'
        },
        cookieAuth: {
          type: 'apiKey',
          in: 'cookie',
          name: 'accessToken'
        }
      },
      schemas: {
        User: {
          type: 'object',
          required: ['email', 'firstName', 'lastName', 'userType'],
          properties: {
            id: {
              type: 'string',
              description: 'User ID'
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'User email address'
            },
            firstName: {
              type: 'string',
              description: 'User first name'
            },
            lastName: {
              type: 'string',
              description: 'User last name'
            },
            fullName: {
              type: 'string',
              description: 'User full name'
            },
            userType: {
              type: 'string',
              enum: ['admin', 'technical', 'customer', 'vendor'],
              description: 'User type/role'
            },
            companyName: {
              type: 'string',
              description: 'Company name'
            },
            vesselType: {
              type: 'string',
              enum: ['cargo', 'tanker', 'container', 'bulk_carrier', 'cruise', 'fishing', 'offshore', 'other'],
              description: 'Type of vessel'
            },
            preferredCurrency: {
              type: 'string',
              enum: ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR'],
              description: 'Preferred currency'
            },
            isVerified: {
              type: 'boolean',
              description: 'Whether user is verified'
            },
            lastLogin: {
              type: 'string',
              format: 'date-time',
              description: 'Last login timestamp'
            }
          }
        },
        Tenant: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'Tenant ID'
            },
            name: {
              type: 'string',
              description: 'Tenant name'
            },
            slug: {
              type: 'string',
              description: 'Tenant slug'
            },
            subscription: {
              type: 'object',
              properties: {
                plan: {
                  type: 'string',
                  enum: ['basic', 'standard', 'premium', 'enterprise']
                },
                status: {
                  type: 'string',
                  enum: ['active', 'inactive', 'suspended', 'trial', 'cancelled']
                }
              }
            }
          }
        },
        AuthResponse: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              description: 'Response message'
            },
            token: {
              type: 'string',
              description: 'JWT access token'
            },
            user: {
              $ref: '#/components/schemas/User'
            },
            tenant: {
              $ref: '#/components/schemas/Tenant'
            }
          }
        },
        Error: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              description: 'Error message'
            },
            errors: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  field: {
                    type: 'string'
                  },
                  message: {
                    type: 'string'
                  }
                }
              }
            }
          }
        }
      }
    },
    security: [
      {
        bearerAuth: []
      },
      {
        cookieAuth: []
      }
    ]
  },
  apis: ['./src/routes/*.js'] // Path to the API files
};

const specs = swaggerJsdoc(options);

const setupSwagger = (app) => {
  // Swagger UI
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs, {
    explorer: true,
    customCss: '.swagger-ui .topbar { display: none }',
    customSiteTitle: 'Maritime Procurement ERP API Documentation',
    swaggerOptions: {
      persistAuthorization: true,
      displayRequestDuration: true
    }
  }));

  // JSON endpoint
  app.get('/api-docs.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(specs);
  });
};

module.exports = { setupSwagger };
