import React, { useEffect, useState } from "react";
import {
  Modal,
  Form,
  Input,
  Button,
  DatePicker,
  Select,
  Space,
  Row,
  Col,
  notification,
  Spin,
} from "antd";
import { CalendarOutlined } from "@ant-design/icons";
import {
  useAPICreateEvent,
  CreateEventRequest,
} from "@/hook/api/event/useAPICreateEvent";
import { useAPIUpdateEventOverview } from "@/hook/api/event/useAPIUpdateEventOverview";
import { useAPIGetVenues } from "@/hook/api/venue/useAPIGetVenues";
import { useAPIGetCreators } from "@/hook/api/creator/useAPIGetCreators";
import { Venue, Creator, User, Event } from "@/type";
import dayjs from "dayjs";
import { useAPIAuthenticate } from "@/hook/api/auth/useAPIAuthenticate";

const { TextArea } = Input;
const { RangePicker } = DatePicker;

interface EventModalProps {
  visible: boolean;
  onCancel: () => void;
  onSuccess: () => void;
  startStep?: "venue" | "form" | "creators";
  event?: Event | null; // 編集対象のイベント
  //   mode?: "create" | "edit"; // モードを明示的に指定
}

const EventModal: React.FC<EventModalProps> = ({
  visible,
  onCancel,
  onSuccess,
  startStep,
  event,
}) => {
  const [form] = Form.useForm();
  const isEditMode = event;
  const [currentStep, setCurrentStep] = useState<"venue" | "form" | "creators">(
    startStep || "venue"
  );
  const [selectedVenueId, setSelectedVenueId] = useState<number | undefined>(
    event ? event.venue.id : undefined
  );
  const [selectedCreatorIds, setSelectedCreatorIds] = useState<number[]>(
    event
      ? event.creatorEvents.map((creatorEvent) => creatorEvent.creator.id)
      : []
  );
  const [formValues, setFormValues] = useState<CreateEventRequest>({
    venueId: 0,
    title: "",
    description: "",
    startDate: new Date(),
    endDate: new Date(),
    creatorIds: [],
  });
  const [user, setUser] = useState<User | undefined>(undefined);

  const { mutate: mutateAuthenticate } = useAPIAuthenticate({
    onSuccess: (user) => {
      setUser(user);
    },
    onError: (error) => {
      notification.error({
        message: "ログインに失敗しました",
        description: error.message,
      });
      onCancel();
    },
  });

  useEffect(() => {
    mutateAuthenticate();
  }, []);

  const { data: venues, isLoading: venuesLoading } = useAPIGetVenues(user?.id);
  const { data: creators, isLoading: creatorsLoading } = useAPIGetCreators();

  const { mutate: mutateCreateEvent, isLoading: isCreating } =
    useAPICreateEvent({
      onSuccess: (data) => {
        notification.success({
          message: "イベントを作成しました",
        });
        onSuccess();
        handleCancel();
      },
      onError: () => {
        notification.error({
          message: "イベントの作成に失敗しました",
        });
      },
    });

  const { mutate: mutateUpdateEventOverview, isLoading: isUpdating } =
    useAPIUpdateEventOverview({
      onSuccess: () => {
        notification.success({
          message: "イベント概要を更新しました",
        });
        onSuccess();
        handleCancel();
      },
      onError: () => {
        notification.error({
          message: "イベント概要の更新に失敗しました",
        });
      },
    });

  useEffect(() => {
    if (visible) {
      if (isEditMode) {
        // 編集モードの場合、既存データでフォームを初期化
        form.setFieldsValue({
          title: event.title,
          description: event.description,
          dateRange: [dayjs(event.startDate), dayjs(event.endDate)],
        });
        setSelectedVenueId(event.venue.id);
        setSelectedCreatorIds(
          event.creatorEvents.length > 0
            ? event.creatorEvents.map((creatorEvent) => creatorEvent.creator.id)
            : []
        );
        setCurrentStep("form");
      } else {
        // 作成モードの場合、フォームをリセット
        form.resetFields();
        setSelectedVenueId(undefined);
        setSelectedCreatorIds([]);
        setCurrentStep("venue");
      }
    }
  }, [visible, form, isEditMode, event]);

  const handleVenueSelect = (venueId: number) => {
    setSelectedVenueId(venueId);
    setCurrentStep("form");
  };

  const handleSubmit = async (values: any) => {
    const { dateRange } = values;
    if (isEditMode && event) {
      mutateUpdateEventOverview({
        eventId: event.id,
        title: values.title,
        description: values.description,
        startDate: dateRange[0].toDate(),
        endDate: dateRange[1].toDate(),
      });
    } else {
      setFormValues({
        ...values,
        startDate: dateRange[0].toDate(),
        endDate: dateRange[1].toDate(),
      });
      setCurrentStep("creators");
    }
  };

  const handleCreatorSelection = () => {
    if (isEditMode) {
      // 編集モードの場合、クリエイター情報も更新
      //   const eventData: UpdateEventRequest = {
      //     id: editEvent.id,
      //     title: editEvent.title,
      //     description: editEvent.description,
      //     startDate: editEvent.startDate,
      //     endDate: editEvent.endDate,
      //     venueId: editEvent.venue.id,
      //     creatorIds: selectedCreatorIds,
      //   };
      //   mutateUpdateEvent(eventData);
    } else {
      mutateCreateEvent({ ...formValues, creatorIds: selectedCreatorIds });
    }
  };

  const handleCancel = () => {
    form.resetFields();
    setSelectedVenueId(undefined);
    setSelectedCreatorIds([]);
    setCurrentStep("venue");
    onCancel();
  };

  const handleBackToVenue = () => {
    if (!isEditMode) {
      setCurrentStep("venue");
      setSelectedVenueId(undefined);
    }
  };

  const venueOptions =
    venues?.map((venue: Venue) => ({
      label: venue.name,
      value: venue.id,
    })) || [];

  const creatorOptions =
    creators?.map((creator: Creator) => ({
      label: creator.name,
      value: creator.id,
    })) || [];

  const renderVenueSelection = () => (
    <div style={{ padding: "20px 0" }}>
      <div style={{ marginBottom: "20px" }}>
        <h3>会場を選択してください</h3>
        <p style={{ color: "#666" }}>
          イベントを開催する会場を選択してください。
        </p>
      </div>
      {venuesLoading ? (
        <div style={{ textAlign: "center", padding: "40px" }}>
          <Spin size="large" />
        </div>
      ) : (
        <Select
          placeholder="会場を選択してください"
          style={{ width: "100%" }}
          size="large"
          value={selectedVenueId}
          onChange={handleVenueSelect}
          options={venueOptions}
          showSearch
          filterOption={(input, option) =>
            (option?.label ?? "").toLowerCase().includes(input.toLowerCase())
          }
        />
      )}
    </div>
  );

  const renderEventForm = () => (
    <Form
      form={form}
      layout="vertical"
      onFinish={handleSubmit}
      autoComplete="off"
    >
      <div style={{ marginBottom: "20px" }}>
        <h3>
          {isEditMode
            ? "イベント情報を編集してください"
            : "イベント情報を入力してください"}
        </h3>
        <p style={{ color: "#666" }}>
          選択した会場:{" "}
          <strong>{venues?.find((v) => v.id === selectedVenueId)?.name}</strong>
        </p>
      </div>

      <Row gutter={16}>
        <Col span={24}>
          <Form.Item
            label="イベント名"
            name="title"
            rules={[
              { required: true, message: "イベント名を入力してください" },
              { max: 255, message: "255文字以内で入力してください" },
            ]}
          >
            <Input placeholder="イベント名を入力してください" />
          </Form.Item>
        </Col>
      </Row>

      <Form.Item
        label="説明"
        name="description"
        rules={[{ max: 1000, message: "1000文字以内で入力してください" }]}
      >
        <TextArea
          rows={4}
          placeholder="イベントの説明を入力してください"
          showCount
          maxLength={1000}
        />
      </Form.Item>

      <Row gutter={16}>
        <Col span={24}>
          <Form.Item
            label="開催期間"
            name="dateRange"
            rules={[{ required: true, message: "開催期間を選択してください" }]}
          >
            <RangePicker
              showTime
              format="YYYY-MM-DD HH:mm"
              placeholder={["開始日時", "終了日時"]}
              style={{ width: "100%" }}
              disabledDate={(current) =>
                current && current < dayjs().startOf("day")
              }
            />
          </Form.Item>
        </Col>
      </Row>

      <Form.Item style={{ marginBottom: 0, textAlign: "right" }}>
        <Space>
          {!isEditMode && (
            <Button onClick={handleBackToVenue}>会場選択に戻る</Button>
          )}
          <Button onClick={handleCancel}>キャンセル</Button>
          <Button
            type="primary"
            htmlType="submit"
            loading={isCreating}
            icon={<CalendarOutlined />}
          >
            {isEditMode ? "イベントを更新" : "イベントを作成"}
          </Button>
        </Space>
      </Form.Item>
    </Form>
  );

  const renderCreatorSelection = () => (
    <div style={{ padding: "20px 0" }}>
      <div style={{ marginBottom: "20px" }}>
        <h3>クリエイターを選択してください</h3>
        <p style={{ color: "#666" }}>
          参加依頼するクリエイターを選択してください。後から変更することも可能です。
        </p>
      </div>

      {creatorsLoading ? (
        <div style={{ textAlign: "center", padding: "40px" }}>
          <Spin size="large" />
        </div>
      ) : (
        <>
          <Select
            mode="multiple"
            placeholder="参加クリエイターを選択してください"
            style={{ width: "100%", marginBottom: "20px" }}
            size="large"
            value={selectedCreatorIds}
            onChange={setSelectedCreatorIds}
            options={creatorOptions}
            showSearch
            filterOption={(input, option) =>
              (option?.label ?? "").toLowerCase().includes(input.toLowerCase())
            }
          />

          <div style={{ textAlign: "right" }}>
            <Space>
              <Button onClick={handleCancel}>キャンセル</Button>
              <Button
                type="primary"
                onClick={handleCreatorSelection}
                loading={isCreating}
                icon={<CalendarOutlined />}
              >
                完了
              </Button>
            </Space>
          </div>
        </>
      )}
    </div>
  );

  const getModalTitle = () => {
    if (isEditMode) {
      switch (currentStep) {
        case "form":
          return "イベント編集";
        case "creators":
          return "クリエイター編集";
        default:
          return "イベント編集";
      }
    } else {
      switch (currentStep) {
        case "venue":
          return "会場選択";
        case "form":
          return "イベント作成";
        case "creators":
          return "クリエイター選択";
        default:
          return "イベント作成";
      }
    }
  };

  return (
    <Modal
      title={getModalTitle()}
      open={visible}
      onCancel={handleCancel}
      footer={null}
      width={800}
      destroyOnClose
    >
      {!isEditMode && currentStep === "venue" && renderVenueSelection()}
      {currentStep === "form" && renderEventForm()}
      {currentStep === "creators" && renderCreatorSelection()}
    </Modal>
  );
};

export default EventModal;
