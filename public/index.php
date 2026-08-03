<?php

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Slim\Factory\AppFactory;
use Slim\Routing\RouteCollectorProxy;

require __DIR__ . '/../vendor/autoload.php';

// -----------------------------------------------------------------------
// CONFIG
// -----------------------------------------------------------------------
require_once __DIR__ . '/../config.php';

// -----------------------------------------------------------------------
// DATABASE CONNECTION (PDO)
// -----------------------------------------------------------------------
function getDB(): PDO
{
    static $db = null;

    if ($db === null) {
        $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4';
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];

        try {
            $db = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode([
                'status'  => 'error',
                'message' => 'Database connection failed: ' . $e->getMessage(),
            ]);
            exit;
        }
    }

    return $db;
}

// -----------------------------------------------------------------------
// APP SETUP
// -----------------------------------------------------------------------
$app = AppFactory::create();
$app->setBasePath('/' . basename(dirname(__DIR__)) . '/public');
$app->addBodyParsingMiddleware();
$app->addRoutingMiddleware();
$app->addErrorMiddleware(true, true, true);

// -----------------------------------------------------------------------
// HELPER: send a JSON response
// -----------------------------------------------------------------------
function jsonResponse(Response $response, $data, int $status = 200): Response
{
    $response->getBody()->write(json_encode($data));
    return $response->withHeader('Content-Type', 'application/json')->withStatus($status);
}

// -----------------------------------------------------------------------
// TOKEN MIDDLEWARE (protects everything under /api)
// -----------------------------------------------------------------------
$tokenMiddleware = function (Request $request, RequestHandler $handler) {
    $authHeader = $request->getHeaderLine('Authorization');

    if (!$authHeader || stripos($authHeader, 'Bearer ') !== 0) {
        $response = new \Slim\Psr7\Response();
        return jsonResponse($response, [
            'status'  => 'error',
            'message' => 'Unauthorized access. Valid API token is required.',
        ], 401);
    }

    $token = trim(substr($authHeader, 7));

    if ($token !== API_TOKEN) {
        $response = new \Slim\Psr7\Response();
        return jsonResponse($response, [
            'status'  => 'error',
            'message' => 'Unauthorized access. Valid API token is required.',
        ], 401);
    }

    return $handler->handle($request);
};

// -----------------------------------------------------------------------
// PUBLIC ROUTE (no token required)
// -----------------------------------------------------------------------
$app->get('/', function (Request $request, Response $response) {
    return jsonResponse($response, [
        'message' => 'Welcome to the Secured Filipino Cookbook API',
        'note'    => 'Use a valid Bearer token to access /api endpoints.',
    ]);
});

// -----------------------------------------------------------------------
// PROTECTED ROUTES (/api/*)
// -----------------------------------------------------------------------
$app->group('/api', function (RouteCollectorProxy $group) {

    // 2. GET /api/foods - all foods with category, origin, ingredients
    $group->get('/foods', function (Request $request, Response $response) {
        $db = getDB();

        $foods = $db->query("
            SELECT f.food_id, f.food_name, c.category_name, o.origin_name, f.instructions
            FROM foods f
            JOIN categories c ON f.category_id = c.category_id
            JOIN origins o ON f.origin_id = o.origin_id
            ORDER BY f.food_id
        ")->fetchAll();

        $ingStmt = $db->prepare("
            SELECT i.ingredient_name
            FROM food_ingredients fi
            JOIN ingredients i ON fi.ingredient_id = i.ingredient_id
            WHERE fi.food_id = :food_id
            ORDER BY i.ingredient_name
        ");

        foreach ($foods as &$food) {
            $ingStmt->execute(['food_id' => $food['food_id']]);
            $food['ingredients'] = $ingStmt->fetchAll(PDO::FETCH_COLUMN);
        }

        return jsonResponse($response, $foods);
    });

    // 3. GET /api/foods/{id} - single food by id
    $group->get('/foods/{id}', function (Request $request, Response $response, array $args) {
        $db = getDB();
        $id = $args['id'];

        $stmt = $db->prepare("
            SELECT f.food_id, f.food_name, c.category_name, o.origin_name, f.instructions
            FROM foods f
            JOIN categories c ON f.category_id = c.category_id
            JOIN origins o ON f.origin_id = o.origin_id
            WHERE f.food_id = :id
        ");
        $stmt->execute(['id' => $id]);
        $food = $stmt->fetch();

        if (!$food) {
            return jsonResponse($response, [
                'status'  => 'error',
                'message' => 'Food not found',
            ], 404);
        }

        $ingStmt = $db->prepare("
            SELECT i.ingredient_name
            FROM food_ingredients fi
            JOIN ingredients i ON fi.ingredient_id = i.ingredient_id
            WHERE fi.food_id = :id
            ORDER BY i.ingredient_name
        ");
        $ingStmt->execute(['id' => $id]);
        $food['ingredients'] = $ingStmt->fetchAll(PDO::FETCH_COLUMN);

        return jsonResponse($response, $food);
    });

    // 4. GET /api/foods/search/{name} - search food by name
    $group->get('/foods/search/{name}', function (Request $request, Response $response, array $args) {
        $db = getDB();
        $name = $args['name'];

        $stmt = $db->prepare("
            SELECT f.food_id, f.food_name, c.category_name, o.origin_name, f.instructions
            FROM foods f
            JOIN categories c ON f.category_id = c.category_id
            JOIN origins o ON f.origin_id = o.origin_id
            WHERE f.food_name LIKE :name
            ORDER BY f.food_name
        ");
        $stmt->execute(['name' => '%' . $name . '%']);
        $foods = $stmt->fetchAll();

        $ingStmt = $db->prepare("
            SELECT i.ingredient_name
            FROM food_ingredients fi
            JOIN ingredients i ON fi.ingredient_id = i.ingredient_id
            WHERE fi.food_id = :food_id
            ORDER BY i.ingredient_name
        ");

        foreach ($foods as &$food) {
            $ingStmt->execute(['food_id' => $food['food_id']]);
            $food['ingredients'] = $ingStmt->fetchAll(PDO::FETCH_COLUMN);
        }

        return jsonResponse($response, $foods);
    });

    // 5. GET /api/categories - all categories
    $group->get('/categories', function (Request $request, Response $response) {
        $db = getDB();
        $categories = $db->query("SELECT * FROM categories ORDER BY category_id")->fetchAll();
        return jsonResponse($response, $categories);
    });

    // 6. GET /api/ingredients - all ingredients
    $group->get('/ingredients', function (Request $request, Response $response) {
        $db = getDB();
        $ingredients = $db->query("SELECT * FROM ingredients ORDER BY ingredient_id")->fetchAll();
        return jsonResponse($response, $ingredients);
    });

    // 7. POST /api/foods - add a new food
    $group->post('/foods', function (Request $request, Response $response) {
        $db = getDB();
        $data = $request->getParsedBody();

        $foodName      = $data['food_name'] ?? null;
        $categoryId    = $data['category_id'] ?? null;
        $originId      = $data['origin_id'] ?? null;
        $instructions  = $data['instructions'] ?? null;
        $ingredientIds = $data['ingredient_ids'] ?? [];

        if (!$foodName || !$categoryId || !$originId || !$instructions) {
            return jsonResponse($response, [
                'status'  => 'error',
                'message' => 'Missing required fields. food_name, category_id, origin_id, and instructions are required.',
            ], 400);
        }

        try {
            $db->beginTransaction();

            $maxId = $db->query("SELECT COALESCE(MAX(food_id), 0) AS max_id FROM foods")->fetch();
            $foodId = (int) $maxId['max_id'] + 1;

            $stmt = $db->prepare("
                INSERT INTO foods (food_id, food_name, category_id, origin_id, instructions)
                VALUES (:food_id, :food_name, :category_id, :origin_id, :instructions)
            ");
            $stmt->execute([
                'food_id'       => $foodId,
                'food_name'     => $foodName,
                'category_id'   => $categoryId,
                'origin_id'     => $originId,
                'instructions'  => $instructions,
            ]);
            if (!empty($ingredientIds)) {
                $ingStmt = $db->prepare("
                    INSERT INTO food_ingredients (food_id, ingredient_id)
                    VALUES (:food_id, :ingredient_id)
                ");
                foreach ($ingredientIds as $ingredientId) {
                    $ingStmt->execute([
                        'food_id'       => $foodId,
                        'ingredient_id' => $ingredientId,
                    ]);
                }
            }

            $db->commit();
        } catch (Exception $e) {
            $db->rollBack();
            return jsonResponse($response, [
                'status'  => 'error',
                'message' => 'Failed to add food: ' . $e->getMessage(),
            ], 500);
        }

        return jsonResponse($response, [
            'status'  => 'success',
            'message' => 'Food added successfully.',
        ], 201);
    });

})->add($tokenMiddleware);

$app->run();
