import React, { useEffect } from "react";
import "antd/dist/reset.css"; // Ant Design の CSS リセット
import type { AppProps } from "next/app";
import { useRouter } from "next/router";
import { useAPIAuthenticate } from "@/hook/api/auth/useAPIAuthenticate";
import { QueryClient, QueryClientProvider } from "react-query";
import { RecoilRoot } from "recoil";
import { useLoginUserMutors } from "@/utils/recoil/loginUser";

const AuthProvider: React.FC<{
  children: React.ReactElement;
}> = ({ children }) => {
  const { setUser, initializeAuth } = useLoginUserMutors();
  const router = useRouter();
  const { mutate: mutateAuthenticate, isLoading } = useAPIAuthenticate({
    onSuccess: (userData) => {
      console.log("Auth check - Current path:", router.pathname);
      if (userData) {
        // 認証成功の場合
        setUser(userData);
        if (userData.id) {
          if (
            router.pathname === "/auth/sign-in" ||
            router.pathname === "/auth/sign-up"
          ) {
            router.push("/");
          }
        }
      } else {
        // トークンが存在しない場合
        setUser(undefined);
        initializeAuth();
      }
    },
    onError: (error) => {
      // 認証エラーの場合
      console.log("Authentication error:", error);
      console.log("Auth check - Current path:", router.pathname);
      router.push("/auth/sign-in");
      // トークンをクリア
      localStorage.removeItem("userToken");
      setUser(undefined);
      initializeAuth();
    },
  });
  useEffect(() => {
    // ベーシック認証
    const basicAuth = () => {
      const auth = localStorage.getItem("basicAuth");
      if (!auth) {
        const username = prompt("ユーザー名を入力してください:");
        const password = prompt("パスワードを入力してください:");
        if (username === "admin" && password === "password") {
          localStorage.setItem("basicAuth", "authenticated");
        } else {
          alert("認証に失敗しました。再試行してください。");
          basicAuth();
        }
      }
    };
    basicAuth();
    // userTokenがあるときだけ認証APIを呼ぶ
    if (localStorage.getItem("userToken")) {
      mutateAuthenticate();
    } else {
      setUser(undefined);
      initializeAuth();
    }
  }, [mutateAuthenticate, setUser, initializeAuth]);
  return <>{children}</>;
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
      <RecoilRoot>
        {/* <AuthProvider> */}
        <Component {...pageProps} />
        {/* </AuthProvider> */}
      </RecoilRoot>
    </QueryClientProvider>
  );
};

export default MyApp;
