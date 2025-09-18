import React, { ReactNode } from "react";
import { Layout, theme } from "antd";
import Sidebar from "@/components/Sidebar";
import Header from "@/components/Header";
import { pageColor } from "@/utils/colors";

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
      <Layout style={{ marginBlockStart: 0, backgroundColor: pageColor }}>
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
