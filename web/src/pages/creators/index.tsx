import React from "react";
import { Card, Row, Col, Spin, Alert, Typography, Avatar, Button } from "antd";
import { UserOutlined, ReloadOutlined, EyeOutlined } from "@ant-design/icons";
import { useAPIGetCreators } from "@/hook/api/creator/useAPIGetCreators";
import { Creator } from "@/type";
import PageLayout from "@/components/common/PageLayout";
import { useRouter } from "next/router";
import "@/styles/pages/Card.scss";

const { Title, Text } = Typography;

const CreatorListPage: React.FC = () => {
  const { data: creators, isLoading, error, refetch } = useAPIGetCreators();
  const router = useRouter();

  if (isLoading) {
    return (
      <PageLayout>
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            height: "50vh",
          }}
        >
          <Spin size="large" />
        </div>
      </PageLayout>
    );
  }

  if (error) {
    return (
      <PageLayout>
        <Alert
          message="エラー"
          description={error.message}
          type="error"
          showIcon
          action={
            <Button size="small" danger onClick={() => refetch()}>
              再試行
            </Button>
          }
        />
      </PageLayout>
    );
  }

  return (
    <PageLayout>
      <div style={{ padding: "24px" }}>
        {creators?.length === 0 ? (
          <Card>
            <div style={{ textAlign: "center", padding: "48px 24px" }}>
              <UserOutlined
                style={{
                  fontSize: "48px",
                  color: "#ccc",
                  marginBottom: "16px",
                }}
              />
              <Title level={4} type="secondary">
                クリエイターが見つかりません
              </Title>
              <Text type="secondary">クリエイターが登録されていません。</Text>
            </div>
          </Card>
        ) : (
          <Row gutter={[24, 24]}>
            {creators?.map((creator: Creator) => (
              <Col xs={24} sm={24} md={12} lg={12} xl={12} key={creator.id}>
                <Card
                  hoverable
                  cover={
                    creator.imageUrl ? (
                      <div style={{ padding: "40px", textAlign: "center" }}>
                        <Avatar
                          size={200}
                          src={creator.imageUrl}
                          icon={<UserOutlined />}
                        />
                      </div>
                    ) : (
                      <div style={{ padding: "40px", textAlign: "center" }}>
                        <Avatar
                          size={200}
                          icon={<UserOutlined />}
                          style={{ backgroundColor: "#f0f0f0", color: "#999" }}
                        />
                      </div>
                    )
                  }
                  onClick={() => router.push(`/creators/${creator.id}`)}
                  //   actions={[
                  //     <Button
                  //       type="link"
                  //       key="detail"
                  //       icon={<EyeOutlined />}
                  //       onClick={() => router.push(`/creators/${creator.id}`)}
                  //     >
                  //       詳細を見る
                  //     </Button>,
                  //   ]}
                  style={{ height: "100%" }}
                >
                  <Card.Meta
                    title={
                      <div
                        style={{ textAlign: "center", marginBottom: "16px" }}
                      >
                        <Title level={3} style={{ margin: 0 }}>
                          {creator.name}
                        </Title>
                      </div>
                    }
                    description={
                      <div style={{ textAlign: "center", minHeight: "100px" }}>
                        {creator.description ? (
                          <Text type="secondary" style={{ fontSize: "16px" }}>
                            {creator.description}
                          </Text>
                        ) : (
                          <Text type="secondary" style={{ fontSize: "16px" }}>
                            プロフィール情報がありません
                          </Text>
                        )}
                      </div>
                    }
                  />
                </Card>
              </Col>
            ))}
          </Row>
        )}
      </div>
    </PageLayout>
  );
};

export default CreatorListPage;
