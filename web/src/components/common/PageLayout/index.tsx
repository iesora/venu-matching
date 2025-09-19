import React, { ReactNode, useEffect, useState } from "react";
import { Layout, theme } from "antd";
import Sidebar from "@/components/Sidebar";
import Header from "@/components/Header";
import { pageColor } from "@/utils/colors";
import Bottombar from "./Bottombar";

const { Content, Footer, Header: AntdHeader } = Layout;

interface PageLayoutProps {
  children: ReactNode;
}

const PageLayout: React.FC<PageLayoutProps> = ({ children }) => {
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();
  const [isBottombarOpen, setIsBottombarOpen] = useState(false);
  // レスポンシブ対応：ウィンドウ幅が 767px 以下の場合は Sidebar を閉じる
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth <= 767) {
        setIsBottombarOpen(true);
      }
    };

    window.addEventListener("resize", handleResize);
    // 初回チェック
    handleResize();

    return () => {
      window.removeEventListener("resize", handleResize);
    };
  }, []);

  // ボトムバーの高さを70に変更
  const bottombarHeight = 60;
  return (
    <Layout style={{ minHeight: "100vh" }}>
      {!isBottombarOpen && <Header />}
      <Layout
        style={{
          marginBlockStart: 0,
          backgroundColor: pageColor,
          marginTop: isBottombarOpen ? 0 : 80,
        }}
      >
        {isBottombarOpen && (
          <AntdHeader
            style={{
              position: "fixed",
              bottom: 0,
              left: 0,
              right: 0,
              zIndex: 100,
              padding: 0,
              background: "transparent",
              height: bottombarHeight,
            }}
          >
            <Bottombar />
          </AntdHeader>
        )}
        <Content style={{ margin: "16px 16px" }}>
          <div
            style={{
              background: pageColor,
              minHeight: 280,
              padding: 24,
              borderRadius: borderRadiusLG,
            }}
          >
            {children}
          </div>
        </Content>
      </Layout>
    </Layout>
  );
};

export default PageLayout;
