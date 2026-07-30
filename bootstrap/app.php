<?php

// 1. Definiramo Kernel klasu
namespace App\Http {
    use Illuminate\Foundation\Http\Kernel as HttpKernel;
    if (!class_exists('App\Http\Kernel')) {
        class Kernel extends HttpKernel {
            protected $middleware = [
                \Illuminate\Http\Middleware\HandleCors::class,
                \Illuminate\Foundation\Http\Middleware\TransformsRequest::class,
                \Illuminate\Foundation\Http\Middleware\ValidatePostSize::class,
                \Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull::class,
            ];
            protected $middlewareGroups = [
                'web' => [
                    \Illuminate\Cookie\Middleware\EncryptCookies::class,
                    \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
                    \Illuminate\Session\Middleware\StartSession::class,
                    \Illuminate\View\Middleware\ShareErrorsFromSession::class,
                    \Illuminate\Routing\Middleware\SubstituteBindings::class,
                ],
                'api' => [
                    \Illuminate\Routing\Middleware\ThrottleRequests::class.':api',
                    \Illuminate\Routing\Middleware\SubstituteBindings::class,
                ],
            ];
            protected $middlewareAliases = [
                'auth' => \Illuminate\Auth\Middleware\Authenticate::class,
                'can' => \Illuminate\Auth\Middleware\Authorize::class,
                'guest' => \Illuminate\Auth\Middleware\RedirectIfAuthenticated::class,
                'throttle' => \Illuminate\Routing\Middleware\ThrottleRequests::class,
            ];
        }
    }
}

// 2. Definiramo Exception Handler klasu
namespace App\Exceptions {
    use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
    use Throwable;
    if (!class_exists('App\Exceptions\Handler')) {
        class Handler extends ExceptionHandler {
            protected $levels = [];
            protected $dontReport = [];
            protected $dontFlash = [
                'current_password',
                'password',
                'password_confirmation',
            ];
            public function register(): void {
                $this->reportable(function (Throwable $e) {
                    //
                });
            }
        }
    }
}

// 3. Pokrećemo Laravel aplikaciju
namespace {
    $app = new Illuminate\Foundation\Application(
        $_ENV['APP_BASE_PATH'] ?? dirname(__DIR__)
    );

    $app->singleton(
        Illuminate\Contracts\Http\Kernel::class,
        App\Http\Kernel::class
    );

    $app->singleton(
        Illuminate\Contracts\Console\Kernel::class,
        App\Console\Kernel::class
    );

    $app->singleton(
        Illuminate\Contracts\Debug\ExceptionHandler::class,
        App\Exceptions\Handler::class
    );

    return $app;
}
