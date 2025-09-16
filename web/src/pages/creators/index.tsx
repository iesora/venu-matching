import React from "react";
import { Card, Row, Col, Spin, Alert, Typography, Avatar, Button } from "antd";
import { UserOutlined, ReloadOutlined, EyeOutlined } from "@ant-design/icons";
import { useAPIGetCreators } from "@/hook/api/creator/useAPIGetCreators";
import { Creator } from "@/type";
import PageLayout from "@/components/common/PageLayout";

const { Title, Text } = Typography;

const CreatorListPage: React.FC = () => {
  const { data: creators, isLoading, error, refetch } = useAPIGetCreators();

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
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "24px",
          }}
        >
          <Title level={2}>クリエイター一覧</Title>
          <Button
            type="primary"
            icon={<ReloadOutlined />}
            onClick={() => refetch()}
            loading={isLoading}
          >
            更新
          </Button>
        </div>

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
          <Row gutter={[16, 16]}>
            {creators?.map((creator: Creator) => (
              <Col xs={24} sm={12} md={8} lg={6} key={creator.id}>
                <Card
                  hoverable
                  cover={
                    creator.profileImageUrl ? (
                      <div style={{ padding: "24px", textAlign: "center" }}>
                        <Avatar
                          size={120}
                          src={creator.profileImageUrl}
                          icon={<UserOutlined />}
                        />
                      </div>
                    ) : (
                      <div style={{ padding: "24px", textAlign: "center" }}>
                        <Avatar
                          size={120}
                          icon={<UserOutlined />}
                          style={{ backgroundColor: "#f0f0f0", color: "#999" }}
                        />
                      </div>
                    )
                  }
                  actions={[
                    <Button type="link" key="detail" icon={<EyeOutlined />}>
                      詳細を見る
                    </Button>,
                  ]}
                >
                  <Card.Meta
                    title={
                      <div style={{ textAlign: "center" }}>
                        <Title level={4} style={{ margin: 0 }}>
                          {creator.name}
                        </Title>
                      </div>
                    }
                    description={
                      <div style={{ textAlign: "center", marginTop: "12px" }}>
                        {creator.description ? (
                          <Text type="secondary">{creator.description}</Text>
                        ) : (
                          <Text type="secondary">
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
