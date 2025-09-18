import { Layout, Menu, MenuProps } from "antd";
import { themeColor, themeColorDeep } from "@/utils/colors";
import { HomeOutlined } from "@ant-design/icons";
import { CalendarOutlined } from "@ant-design/icons";
import { EnvironmentOutlined } from "@ant-design/icons";
import { TeamOutlined } from "@ant-design/icons";
import { LogoutOutlined } from "@ant-design/icons";
import { useRouter } from "next/router";
import "@/styles/pages/Header.scss";

const { Header: AntdHeader } = Layout;

const Header = () => {
  const router = useRouter();
  const currentPath = router.pathname || "/";

  const handleMenuClick: MenuProps["onClick"] = ({ key }) => {
    if (key === "logout") {
      if (confirm("ログアウトしますか？")) {
        localStorage.removeItem("userToken");
        router.reload();
      }
      return;
    }
    router.push(key);
  };

  const menuItems: MenuProps["items"] = [
    {
      key: "/",
      icon: <HomeOutlined />,
      label: "ホーム",
    },
    {
      key: "/events",
      icon: <CalendarOutlined />,
      label: "イベント",
    },
    {
      key: "/venues",
      icon: <EnvironmentOutlined />,
      label: "会場",
    },
    {
      key: "/creators",
      icon: <TeamOutlined />,
      label: "クリエイター",
    },
    {
      key: "logout",
      icon: <LogoutOutlined />,
      label: "ログアウト",
    },
  ];
  return (
    <AntdHeader
      style={{
        backgroundColor: themeColor,
        height: 80,
        lineHeight: "80px",
        display: "flex",
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "space-between",
        width: "100%",
        borderBottom: "1px solid #e0e0e0",
        position: "fixed",
        top: 0,
        left: 0,
        right: 0,
        zIndex: 1000,
      }}
      className="header"
    >
      <img src={"/vmlogo.png"} alt="logo" style={{ width: 95, height: 80 }} />

      <div style={{ width: "80%", overflowX: "auto" }}>
        <Menu
          mode="horizontal"
          selectedKeys={[currentPath]}
          onClick={handleMenuClick}
          items={menuItems}
          style={{
            flex: 1,
            justifyContent: "right",
            backgroundColor: themeColor,
          }}
        />
      </div>
    </AntdHeader>
  );
};

export default Header;
