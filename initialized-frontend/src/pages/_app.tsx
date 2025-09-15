import React, { useEffect } from "react";
import "antd/dist/reset.css"; // Ant Design の CSS リセット
import type { AppProps } from "next/app";
import { useRouter } from "next/router";
import { useAPIAuthenticate } from "@/hook/api/auth/useAPIAuthenticate";
import { QueryClient, QueryClientProvider } from "react-query";
import { Spin } from "antd";

const AuthProvider: React.FC<{
  children: React.ReactElement;
}> = ({ children }) => {
  const router = useRouter();

  const { mutate: mutateAuthenticate, isLoading } = useAPIAuthenticate({
    onSuccess: (userData) => {
      if (userData && userData.id) {
        if (
          router.pathname === "/auth/sign-in" ||
          router.pathname === "/auth/sign-up"
        ) {
          router.push("/");
        }
      }
    },
    //トークンが間違ってる時
    onError: () => {
      if (
        router.pathname === "/" ||
        router.pathname === "/reservation" ||
        router.pathname === "/staff" ||
        router.pathname === "/course" ||
        router.pathname === "/setting"
      ) {
        router.push("/auth/sign-in");
      }
    },
  });

  // 初回レンダリング時に認証を実行
  useEffect(() => {
    mutateAuthenticate();
  }, [mutateAuthenticate]);

  // ルート変更時にも毎回認証を行う
  useEffect(() => {
    const handleRouteChange = () => {
      mutateAuthenticate();
    };
    router.events.on("routeChangeStart", handleRouteChange);
    return () => {
      router.events.off("routeChangeStart", handleRouteChange);
    };
  }, [mutateAuthenticate, router.events]);

  return (
    <>
      {children}
      {isLoading && (
        <div
          style={{
            position: "fixed",
            top: 0,
            left: 0,
            width: "100vw",
            height: "100vh",
            backgroundColor: "rgba(255,255,255,0)",
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            zIndex: 9999,
          }}
        >
          <Spin size="large" />
        </div>
      )}
    </>
  );
};

const MyApp = ({ Component, pageProps }: AppProps) => {
  const theme = {
    styles: {
      global: {
        "html, body": {
          overflow: "hidden",
          width: "100%",
          position: "relative",
          padding: 0,
          margin: 0,
          background: "#f4f4f4",
          lineHeight: "100%",
          fontFamily:
            "'游ゴシック体', YuGothic, '游ゴシック', 'Yu Gothic', sans-serif",
        },
      },
    },
  };

  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        refetchOnWindowFocus: false,
      },
    },
  });
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <Component {...pageProps} />
      </AuthProvider>
    </QueryClientProvider>
  );
};

export default MyApp;
