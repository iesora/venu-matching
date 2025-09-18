import React, { ReactNode } from "react";
import { Layout, theme } from "antd";
import Sidebar from "@/components/Sidebar";
import Header from "@/components/Header";
import { themeColor } from "@/utils/colors";

const { Content, Footer } = Layout;

interface PageLayoutProps {
  children: ReactNode;
}

const PageLayout: React.FC<PageLayoutProps> = ({ children }) => {
  const {
    token: { colorBgContainer, borderRadiusLG },
  } = theme.useToken();
  return (
    <Layout style={{ minHeight: "100vh" }}>
      <Header />
      <Layout style={{ marginBlockStart: 0, backgroundColor: themeColor }}>
        <Content style={{ margin: "16px 16px" }}>
          <div
            style={{
              background: themeColor,
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
