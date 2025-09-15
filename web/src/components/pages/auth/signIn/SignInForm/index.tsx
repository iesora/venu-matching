import React from "react";
import { Input, Button, Form } from "antd";
import { useLogin } from "@/hook/api/auth/useAPILogin";
import { useRouter } from "next/router";

type FieldType = {
  email: string;
  password: string;
};

const SignInForm = () => {
  const { mutate: login } = useLogin();
  const router = useRouter();
  const [form] = Form.useForm();
  const handleSubmit = (values: FieldType) => {
    login(
      {
        email: values.email,
        password: values.password,
      },
      {
        onSuccess: (response) => {
          const asyncLocalStorage = {
            setItem: async function (key: string, value: string) {
              return Promise.resolve().then(function () {
                localStorage.setItem(key, value);
              });
            },
            getItem: async function (key: string): Promise<string> {
              return Promise.resolve().then(function () {
                return localStorage.getItem(key) || "";
              });
            },
          };
          asyncLocalStorage
            .setItem("userToken", response.token || "")
            .then(function (): Promise<string> {
              return asyncLocalStorage.getItem("userToken");
            })
            .then(function (value) {
              if (value) {
                router.push("/");
              }
            });
          setTimeout(() => {
            router.push("/");
          }, 3000);
        },
        onError: () => {
          alert("ログインに失敗しました。");
        },
      }
    );
  };

  return (
    <>
      <div className="authenticationdiv">
        <div
          style={{
            maxWidth: "510px",
            marginLeft: "auto",
            marginRight: "auto",
            padding: "50px 0 100px",
          }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "center",
              fontSize: "28px",
              fontWeight: "700",
              marginBottom: "40px",
            }}
          >
            Venue-Matching
          </div>
          {/*
          <div fontSize="15px" mb="12px">
            &nbsp;アカウントを持っていない場合：{" "}
            <Button
              alignItems="center"
              variant="unstyled"
              color="blue"
              onClick={() => {
                router.push("/auth/sign-up");
              }}
            >
              &nbsp;&nbsp;アカウント作成
            </Button>
          </div>
          */}

          {/*<FormControl noValidate onSubmit={handleSubmit}>*/}
          <Form form={form} onFinish={handleSubmit}>
            <div
              style={{
                background: "#fff",
                padding: "30px 20px",
                borderRadius: "10px",
                marginBottom: "20px",
                boxShadow: "0px 1px 12px 1px rgba(0,0,0,0.05)",
              }}
              className="bg-black"
            >
              <div
                style={{
                  fontSize: "20px",
                  fontWeight: "bold",
                  marginBottom: "24px",
                }}
              >
                ログイン
              </div>
              <div style={{ marginBottom: "16px" }}>
                <div
                  style={{
                    fontWeight: "500",
                    fontSize: "14px",
                    marginBottom: "10px",
                    display: "block",
                  }}
                >
                  メールアドレス
                </div>
                <Form.Item<FieldType> name="email">
                  <Input id="email" type="email" name="email" />
                </Form.Item>
              </div>
              <div style={{ marginBottom: "32px" }}>
                <div
                  style={{
                    fontWeight: "500",
                    fontSize: "14px",
                    marginBottom: "10px",
                    display: "block",
                  }}
                >
                  パスワード
                </div>
                <Form.Item<FieldType> name="password">
                  <Input id="password" type="password" name="password" />
                </Form.Item>
              </div>
              <div
                style={{
                  display: "flex",
                  justifyContent: "flex-end",
                  marginRight: "4px",
                }}
              >
                <Form.Item>
                  <Button htmlType="submit">ログイン</Button>
                </Form.Item>
              </div>
            </div>
          </Form>
        </div>
      </div>
    </>
  );
};

export default SignInForm;
